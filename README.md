# Project Nashville — Sklepy v1.1.2

Odtworzona wersja zasobu. Polski panel NUI, ikony SVG, grafiki przedmiotów z `ox_inventory`, kasjerzy `ox_target`, koszyk, płatności ESX oraz zapisywany magazyn. Brak bindów.

## Instalacja

1. Wypakuj `project_nashville_sklepy` do `resources`. Jeśli masz stare pliki, najpierw zrób kopię konfiguracji i magazynu. Stary format danych nie został zweryfikowany; nowa paczka oczekuje JSON w formacie `{ "id_sklepu": { "nazwa_itemu": 10 } }`.
2. Włącz OneSync. Uruchom `ox_lib`, `es_extended`, `ox_target` i `ox_inventory` zgodnie z wymaganiami tych zasobów. Dodaj po nich `ensure project_nashville_sklepy`.
3. Dopasuj itemy oraz współrzędne w `config.lua`. Nieistniejące przedmioty są pomijane z komunikatem w konsoli. Płatności korzystają z kont ESX `money` i `bank`; dostosuj `Config.Kasa` do swojej konfiguracji. Podmień pozycje kasjerów, jeśli korzystasz z niestandardowych wnętrz.
4. Podejdź do kasjera i wybierz „Otwórz sklep” w `ox_target` albo wpisz `/sklep`.

## Ikony

Zasób używa klientowego `Items()` z `ox_inventory` i bierze `client.image`, jeśli je ustawiono. Domyślna nazwa to `<item>.png` w `inventory:imagepath` (domyślnie `ox_inventory/web/images`). Opcjonalne `obraz` w produkcie ma pierwszeństwo. Adresy `nui://` są zamieniane na adresy HTTPS Cfx; własny CDN musi obsługiwać HTTPS. Brak obrazka daje ikonę SVG, nie pustą miniaturę.

## Komendy

- `/sklep` — otwarcie najbliższego sklepu, w zasięgu kasjera.
- `/zamknijsklep` — zamknięcie panelu; działa też przycisk X.
- `/sklepstan ID ITEM [NOWY_STAN]` — odczyt lub zmiana stanu produktu limitowanego.
- `/sklepreset ID` — przywrócenie stanów domyślnych dla wskazanego sklepu.

Przykładowe wpisy do `server.cfg` (dopasuj grupę ACE):

```cfg
add_ace group.admin command.sklepstan allow
add_ace group.admin command.sklepreset allow
ensure project_nashville_sklepy
```

## Eksporty

Klient:
```lua
exports['project_nashville_sklepy']:OtworzSklep('24_7_strawberry')
exports['project_nashville_sklepy']:ZamknijSklep()
local otwarty = exports['project_nashville_sklepy']:CzySklepOtwarty()
```

Serwer:
```lua
local stan = exports['project_nashville_sklepy']:PobierzStan('24_7_strawberry', 'water')
local zapisano = exports['project_nashville_sklepy']:UstawStan('24_7_strawberry', 'water', 50)
```

`nil` oznacza m.in. stan nieograniczony albo nieznaną pozycję. `UstawStan` obsługuje tylko produkty limitowane. Magazyn trafia do `dane_stanow.json` w folderze zasobu; folder musi być zapisywalny i mieć trwały wolumen. To zapis plikowy, nie transakcja bazodanowa odporna na awarie.

## Zakup i test na serwerze

Serwer sprawdza dystans, instancję, cenę z katalogu, ilość, stan magazynu, saldo i miejsce w ekwipunku. Jeśli kolejna pozycja nie zmieści się lub nie zostanie wydana, zakup może być częściowy; płatność dotyczy wyłącznie wydanych pozycji, a NUI zostawia nieodebrane pozycje w koszyku (z uwzględnieniem dostępności).

Przed wdrożeniem sprawdź na serwerze: oba sposoby płatności, pełny ekwipunek, stan po restarcie, test kupna ostatniej sztuki przez dwóch graczy, obrazy z własnego `inventory:imagepath` i zamykanie panelu po odejściu od NPC.

### Hotfix 1.1.2

Przezroczyste tło strony NUI niezależnie od ciemnego motywu panelu. Panel startuje ukryty. Focus jest przyznawany po potwierdzeniu otwarcia przez NUI i zwalniany przy zamknięciu. Aktualizacja wymaga podmiany `client.lua`, `fxmanifest.lua` i katalogu `ui`; nie zmienia konfiguracji ani zapisanych stanów magazynu.
