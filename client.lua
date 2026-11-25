local zasob = GetCurrentResourceName()
local kasjerzy, aktywny, otwieranie, kupowanie = {}, nil, false, false
local numer, maFocus = 0, false
local function powiadom(tekst)
    lib.notify({ title = 'Project Nashville — Sklepy', description = tekst, type = 'error' })
end
local function wzbogac(sklep)
    local sciezka = GetConvar('inventory:imagepath', 'nui://ox_inventory/web/images'):gsub('/+$', '')
    if sciezka == '' then sciezka = 'nui://ox_inventory/web/images' end
    for _, p in ipairs(sklep.produkty or {}) do
        local dane = exports.ox_inventory:Items(p.id)
        local obraz = p.obraz or (dane and dane.client and dane.client.image) or (dane and dane.image)
        if type(obraz) ~= 'string' or obraz == '' then obraz = p.id..'.png' end
        if not obraz:match('^[%w+.-]+://') then obraz = sciezka..'/'..obraz end
        p.obraz = obraz:gsub('^nui://([^/]+)/', 'https://cfx-nui-%1/')
    end
    sklep.limitSztuk, sklep.limitPozycji = Config.LimitSztuk, Config.LimitPozycji
    return sklep
end
local function zamknij()
    if not aktywny then return false end
    aktywny = nil
    if maFocus then
        maFocus = false
        SetNuiFocus(false, false)
    end
    SendNUIMessage({ typ = 'zamknij' })
    return true
end
local function otworz(id)
    if otwieranie or aktywny or kupowanie then return false end
    if not id then
        local pozycja, dystans = GetEntityCoords(PlayerPedId()), Config.Dystans
        for klucz, sklep in pairs(Config.Sklepy) do
            local p = sklep.pozycja
            local d = #(pozycja - vector3(p.x, p.y, p.z))
            if d <= dystans then id, dystans = klucz, d end
        end
    end
    if not id or not Config.Sklepy[id] then powiadom('Podejdź do kasjera.'); return false end
    otwieranie = true
    local ok, wynik = pcall(lib.callback.await, 'nashville:sklep:otworz', false, id)
    otwieranie = false
    if not ok or not wynik then powiadom('Nie udało się połączyć ze sklepem.'); return false end
    if not wynik.ok then powiadom(wynik.tekst); return false end
    local sklep = wzbogac(wynik.sklep)
    aktywny = id
    numer = numer + 1
    local aktualny = numer
    SendNUIMessage({ typ = 'otworz', sklep = sklep, numer = aktualny })
    SetTimeout(3000, function()
        if aktywny and numer == aktualny and not maFocus then
            zamknij()
            powiadom('Panel sklepu nie odpowiedział. Spróbuj ponownie.')
        end
    end)
    return true
end
RegisterCommand('sklep', function() otworz() end, false)
RegisterCommand('zamknijsklep', zamknij, false)
exports('OtworzSklep', otworz)
exports('ZamknijSklep', zamknij)
exports('CzySklepOtwarty', function() return aktywny ~= nil end)
RegisterNUICallback('pokazano', function(d, cb)
    if not aktywny or type(d) ~= 'table' or d.numer ~= numer then
        cb({ ok = false }); return
    end
    if not maFocus then
        maFocus = true
        SetNuiFocus(true, true)
    end
    cb({ ok = true })
end)
RegisterNUICallback('zamknij', function(_, cb) zamknij(); cb({ ok = true }) end)
RegisterNUICallback('kup', function(d, cb)
    if kupowanie or not aktywny or type(d) ~= 'table' then cb({ ok = false, tekst = 'Kasa jest niedostępna.' }); return end
    kupowanie = true
    local ok, wynik = pcall(lib.callback.await, 'nashville:sklep:kup', false, aktywny, d.metoda, d.koszyk)
    kupowanie = false
    if not ok or not wynik then cb({ ok = false, tekst = 'Brak odpowiedzi. Sprawdź saldo i ekwipunek przed ponowieniem.' }); return end
    if wynik.sklep then wynik.sklep = wzbogac(wynik.sklep) end
    cb(wynik)
end)
CreateThread(function()
    for id, sklep in pairs(Config.Sklepy) do
        local klucz = id
        local hash = joaat(sklep.model or Config.Model)
        local ok = pcall(lib.requestModel, hash, 5000)
        if ok then
            local p = sklep.pozycja
            local ped = CreatePed(4, hash, p.x, p.y, p.z - 1.0, p.w, false, false)
            SetModelAsNoLongerNeeded(hash)
            if ped ~= 0 and DoesEntityExist(ped) then
                kasjerzy[klucz] = ped
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                FreezeEntityPosition(ped, true)
                exports.ox_target:addLocalEntity(ped, {{
                    name = 'nashville_sklep_'..klucz, label = 'Otwórz sklep', icon = 'fa-solid fa-basket-shopping',
                    distance = math.min(Config.Dystans, 2.5), onSelect = function() otworz(klucz) end
                }})
            end
        else print('[Sklepy] Nie udało się załadować modelu kasjera: '..klucz) end
    end
end)
CreateThread(function()
    while true do
        Wait(500)
        if aktywny then
            local p = Config.Sklepy[aktywny].pozycja
            local ped = PlayerPedId()
            if IsEntityDead(ped) or #(GetEntityCoords(ped) - vector3(p.x, p.y, p.z)) > Config.Dystans + 0.3 then zamknij() end
        end
    end
end)
AddEventHandler('onResourceStop', function(r)
    if r ~= zasob then return end
    zamknij()
    for id, ped in pairs(kasjerzy) do
        if GetResourceState('ox_target') == 'started' then exports.ox_target:removeLocalEntity(ped, 'nashville_sklep_'..id) end
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)
