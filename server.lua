local ESX = exports.es_extended:getSharedObject()
local ox = exports.ox_inventory
local zasob = GetCurrentResourceName()
local plik = 'dane_stanow.json'
local magazyn, blokada, ostatni = {}, {}, {}
local katalogi, blokadaSklepu = {}, {}
local function liczba(x, min, max)
    return type(x) == 'number' and x % 1 == 0 and x >= min and x <= max
end
local stare = LoadResourceFile(zasob, plik)
if stare and stare ~= '' then
    local ok, wynik = pcall(json.decode, stare)
    if ok and type(wynik) == 'table' then magazyn = wynik
    else print('[Sklepy] Nieprawidłowy JSON magazynu. Sprawdź kopię danych.') end
end
for id, sklep in pairs(Config.Sklepy) do
    local katalog = { lista = {}, poId = {} }
    katalogi[id] = katalog
    if type(magazyn[id]) ~= 'table' then magazyn[id] = {} end
    for _, p in ipairs(Config.Asortyment[sklep.typ] or {}) do
        if type(p.item) == 'string' and liczba(p.cena, 1, 1000000) and not katalog.poId[p.item] then
            if ox:Items(p.item) then
                katalog.lista[#katalog.lista+1] = p
                katalog.poId[p.item] = p
                if liczba(p.stan, 0, 1000000) then
                    if not liczba(magazyn[id][p.item], 0, 1000000) then magazyn[id][p.item] = p.stan end
                else magazyn[id][p.item] = nil end
            else print(('[Sklepy] %s: brak itemu %s w ox_inventory — pomijam.'):format(id, p.item)) end
        end
    end
end
local function zapisz()
    local dane = json.encode(magazyn)
    if not SaveResourceFile(zasob, plik, dane, #dane) then
        print('[Sklepy] Nie zapisano magazynu. Sprawdź uprawnienia zapisu zasobu.')
        return false
    end
    return true
end
local function blisko(src, id)
    local sklep = Config.Sklepy[id]
    if not sklep or GetPlayerRoutingBucket(src) ~= (sklep.bucket or 0) then return false end
    local ped = GetPlayerPed(src)
    if ped == 0 or GetEntityHealth(ped) <= 0 then return false end
    local p = sklep.pozycja
    return #(GetEntityCoords(ped) - vector3(p.x, p.y, p.z)) <= Config.Dystans
end
local function widok(id)
    local sklep, katalog = Config.Sklepy[id], katalogi[id]
    if not sklep or not katalog then return end
    local produkty = {}
    for _, p in ipairs(katalog.lista) do
        local item = ox:Items(p.item)
        if item then
            produkty[#produkty+1] = { id = p.item, nazwa = p.nazwa or item.label or p.item,
                cena = p.cena, kategoria = p.kategoria or 'inne', stan = magazyn[id][p.item], obraz = p.obraz }
        end
    end
    return { id = id, nazwa = sklep.nazwa, produkty = produkty, kategorie = Config.Kategorie }
end
local function blad(tekst, id)
    return { ok = false, tekst = tekst, sklep = id and widok(id) or nil }
end
lib.callback.register('nashville:sklep:otworz', function(src, id)
    if type(id) ~= 'string' or not blisko(src, id) then return blad('Podejdź do kasjera.') end
    if not ESX.GetPlayerFromId(src) then return blad('Postać nie jest jeszcze załadowana.') end
    return { ok = true, sklep = widok(id) }
end)
local function kup(src, id, metoda, koszyk)
    if type(id) ~= 'string' or not blisko(src, id) then return blad('Podejdź do kasjera.') end
    local konto = type(metoda) == 'string' and Config.Kasa[metoda]
    if not konto then return blad('Wybierz poprawną metodę płatności.') end
    if type(koszyk) ~= 'table' or #koszyk < 1 or #koszyk > Config.LimitPozycji then return blad('Niepoprawny koszyk.') end
    local x = ESX.GetPlayerFromId(src)
    if not x then return blad('Postać nie jest dostępna.') end
    local suma, pozycje, uzyte = 0, {}, {}
    for i = 1, #koszyk do
        local linia = koszyk[i]
        if type(linia) ~= 'table' or type(linia.id) ~= 'string' or uzyte[linia.id] or not liczba(linia.ilosc, 1, Config.LimitSztuk) then
            return blad('Niepoprawna pozycja koszyka.')
        end
        local p = katalogi[id].poId[linia.id]
        if not p or not ox:Items(p.item) then return blad('Produkt nie jest dostępny.', id) end
        local stan = magazyn[id][p.item]
        if stan ~= nil and stan < linia.ilosc then return blad('Za mało sztuk: '..(p.nazwa or p.item), id) end
        uzyte[p.item] = true
        suma = suma + p.cena * linia.ilosc
        pozycje[#pozycje+1] = { p = p, ilosc = linia.ilosc }
    end
    local saldo = x.getAccount(konto)
    if not saldo or (tonumber(saldo.money) or 0) < suma then return blad('Brak środków na wybranym koncie.') end
    local wydane, licznik = {}, 0
    -- Kolejne pozycje są rozliczane oddzielnie: gracz płaci wyłącznie za wydane towary.
    for _, l in ipairs(pozycje) do
        local p, n = l.p, l.ilosc
        local kwota = p.cena * n
        local aktualneSaldo = x.getAccount(konto)
        if not aktualneSaldo or (tonumber(aktualneSaldo.money) or 0) < kwota or not ox:CanCarryItem(src, p.item, n) then break end
        x.removeAccountMoney(konto, kwota, 'Project Nashville — zakupy')
        local poprawnie, dodano = pcall(function() return ox:AddItem(src, p.item, n) end)
        if not poprawnie or dodano ~= true then
            x.addAccountMoney(konto, kwota, 'Project Nashville — zwrot')
            if not poprawnie then print(('[Sklepy] Błąd wydania %s: %s'):format(p.item, tostring(dodano))) end
            break
        end
        if magazyn[id][p.item] ~= nil then magazyn[id][p.item] = magazyn[id][p.item] - n end
        wydane[#wydane+1] = { id = p.item, ilosc = n }
        licznik = licznik + kwota
    end
    if #wydane == 0 then return blad('Nie udało się wydać produktów. Sprawdź miejsce w ekwipunku.', id) end
    zapisz()
    local calosc = #wydane == #pozycje
    return { ok = true, czesciowo = not calosc, wydane = wydane, sklep = widok(id),
        tekst = calosc and ('Zakup zakończony. Zapłacono $%d.'):format(licznik)
            or ('Część produktów nie zmieściła się lub nie została wydana. Zapłacono $%d tylko za odebrane towary.'):format(licznik) }
end
lib.callback.register('nashville:sklep:kup', function(src, id, metoda, koszyk)
    local teraz = GetGameTimer()
    if blokada[src] or (ostatni[src] and teraz - ostatni[src] < 750) then return blad('Odczekaj chwilę przed kolejnym zakupem.') end
    if type(id) ~= 'string' or not katalogi[id] then return blad('Nieznany sklep.') end
    if blokadaSklepu[id] then return blad('Kasa jest zajęta. Spróbuj ponownie.') end
    ostatni[src], blokada[src], blokadaSklepu[id] = teraz, true, true
    local ok, wynik = xpcall(function() return kup(src, id, metoda, koszyk) end, debug.traceback)
    blokada[src], blokadaSklepu[id] = nil, nil
    if ok then return wynik end
    print(('[Sklepy] Błąd zakupu gracza %d: %s'):format(src, wynik))
    return blad('Błąd zakupu. Sprawdź ekwipunek i saldo przed ponowieniem.')
end)
AddEventHandler('playerDropped', function() ostatni[source], blokada[source] = nil, nil end)
local function komunikat(src, tekst)
    if src == 0 then print('[Sklepy] '..tekst) else TriggerClientEvent('ox_lib:notify', src, { description = tekst, type = 'inform' }) end
end
local function ustawStan(id, item, stan)
    if blokadaSklepu[id] or not katalogi[id] or not katalogi[id].poId[item] or magazyn[id][item] == nil or not liczba(stan, 0, 1000000) then return false end
    magazyn[id][item] = stan
    return zapisz()
end
RegisterCommand('sklepstan', function(src, args)
    local id, item, wartosc = args[1], args[2], args[3]
    if not id or not item or not magazyn[id] or magazyn[id][item] == nil then return komunikat(src, 'Użycie: /sklepstan ID ITEM [NOWY_STAN] — tylko produkty limitowane.') end
    if wartosc and not ustawStan(id, item, tonumber(wartosc)) then return komunikat(src, 'Nie udało się zapisać. Wartość musi wynosić 0–1000000.') end
    komunikat(src, ('%s / %s: %d szt.'):format(id, item, magazyn[id][item]))
end, true)
RegisterCommand('sklepreset', function(src, args)
    local id = args[1]
    if not id or not katalogi[id] then return komunikat(src, 'Użycie: /sklepreset ID_SKLEPU') end
    if blokadaSklepu[id] then return komunikat(src, 'Kasa jest zajęta. Spróbuj ponownie.') end
    for _, p in ipairs(katalogi[id].lista) do magazyn[id][p.item] = liczba(p.stan, 0, 1000000) and p.stan or nil end
    komunikat(src, zapisz() and 'Przywrócono domyślne stany sklepu.' or 'Błąd zapisu stanów.')
end, true)
exports('PobierzStan', function(id, item) return magazyn[id] and magazyn[id][item] end)
exports('UstawStan', ustawStan)
