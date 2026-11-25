Config = {
    Dystans = 3.0,
    LimitPozycji = 16,
    LimitSztuk = 20,
    Kasa = { gotowka = 'money', karta = 'bank' },
    -- Brak stanu oznacza nieograniczoną dostępność. Stan jest osobny dla każdej placówki.
    Kategorie = {
        napoje = { etykieta = 'Napoje', ikona = 'drink' },
        jedzenie = { etykieta = 'Jedzenie', ikona = 'food' },
        inne = { etykieta = 'Pozostałe', ikona = 'box' },
    },
    Asortyment = {
        spozywczy = {
            { item = 'water', nazwa = 'Woda', cena = 10, kategoria = 'napoje', stan = 180 },
            { item = 'bread', nazwa = 'Chleb', cena = 15, kategoria = 'jedzenie', stan = 120 },
            { item = 'burger', nazwa = 'Burger', cena = 28, kategoria = 'jedzenie', stan = 70 },
            { item = 'cola', nazwa = 'Cola', cena = 16, kategoria = 'napoje', stan = 100 },
        },
        monopolowy = {
            { item = 'water', nazwa = 'Woda', cena = 12, kategoria = 'napoje', stan = 100 },
            { item = 'cola', nazwa = 'Cola', cena = 19, kategoria = 'napoje', stan = 80 },
            { item = 'bread', nazwa = 'Chleb', cena = 17, kategoria = 'jedzenie', stan = 60 },
        },

elektroniczny = {
    { item = 'oxphone18pm_burgundy', nazwa = 'oxPhone 18 Pro Max Burgundy', cena = 12000, kategoria = 'telefony', stan = 100 },
    { item = 'oxphone18pm_black', nazwa = 'oxPhone 18 Pro Max Black', cena = 12000, kategoria = 'telefony', stan = 100 },
    { item = 'oxphone18pm_silver', nazwa = 'oxPhone 18 Pro Max Silver', cena = 12000, kategoria = 'telefony', stan = 100 },
    { item = 'oxphone18pm_blue', nazwa = 'oxPhone 18 Pro Max Deep Blue', cena = 12000, kategoria = 'telefony', stan = 100 },

    { item = 'oxsung_s29u_violet', nazwa = 'oxSung Galaxy S29 Ultra Violet', cena = 11000, kategoria = 'telefony', stan = 100 },
    { item = 'oxsung_s29u_black', nazwa = 'oxSung Galaxy S29 Ultra Black', cena = 11000, kategoria = 'telefony', stan = 100 },
    { item = 'oxsung_s29u_silver', nazwa = 'oxSung Galaxy S29 Ultra Silver', cena = 11000, kategoria = 'telefony', stan = 100 },

    { item = 'oxphoneduo_white', nazwa = 'oxPhone Duo Star White', cena = 9500, kategoria = 'telefony', stan = 100 },
    { item = 'oxphoneduo_night', nazwa = 'oxPhone Duo Night Sky', cena = 9500, kategoria = 'telefony', stan = 100 },
    { item = 'oxphoneduo_rose', nazwa = 'oxPhone Duo Rose Dawn', cena = 9500, kategoria = 'telefony', stan = 100 },
    { item = 'oxphoneduo_blue', nazwa = 'oxPhone Duo Sky Blue', cena = 9500, kategoria = 'telefony', stan = 100 },
},
    },
    Model = 'mp_m_shopkeep_01',
Sklepy = {
    -- Sklepy spożywcze
    ['24_7_strawberry'] = { nazwa = '24/7 Strawberry', typ = 'spozywczy', pozycja = vector4(24.40, -1347.46, 29.49, 270.0) },
    ['24_7_innocence'] = { nazwa = '24/7 Innocence', typ = 'spozywczy', pozycja = vector4(-47.65, -1759.09, 29.42, 50.0) },
    ['24_7_mirror'] = { nazwa = 'LTD Mirror Park', typ = 'spozywczy', pozycja = vector4(1165.02, -324.23, 69.20, 90.0) },
    ['24_7_sandy'] = { nazwa = '24/7 Sandy Shores', typ = 'spozywczy', pozycja = vector4(1959.80, 3739.94, 32.34, 300.0) },
    ['24_7_paleto'] = { nazwa = '24/7 Paleto', typ = 'spozywczy', pozycja = vector4(1727.64, 6414.84, 35.03, 250.0) },
    ['ltd_grapeseed'] = { nazwa = 'LTD Grapeseed', typ = 'spozywczy', pozycja = vector4(1698.03, 4922.85, 42.06, 320.0) },
    ['24_7_senora'] = { nazwa = '24/7 Senora Freeway', typ = 'spozywczy', pozycja = vector4(2678.14, 3279.27, 55.24, 320.0) },
    ['24_7_harmony'] = { nazwa = '24/7 Harmony', typ = 'spozywczy', pozycja = vector4(549.04, 2671.56, 42.15, 100.0) },
    ['24_7_chumash_polnoc'] = { nazwa = '24/7 Chumash Północ', typ = 'spozywczy', pozycja = vector4(-3242.28, 999.92, 12.83, 10.0) },
    ['ltd_richman_glen'] = { nazwa = 'LTD Richman Glen', typ = 'spozywczy', pozycja = vector4(-1819.23, 793.30, 138.08, 120.0) },
    ['24_7_chumash'] = { nazwa = '24/7 Chumash', typ = 'spozywczy', pozycja = vector4(-3038.85, 584.5, 7.90, 10.0) },
    ['24_7_vinewood'] = { nazwa = '24/7 Vinewood', typ = 'spozywczy', pozycja = vector4(372.54, 326.61, 103.56, 250.0) },
    ['24_7_tataviam'] = { nazwa = '24/7 Tataviam', typ = 'spozywczy', pozycja = vector4(2557.17, 380.76, 108.62, 340.0) },
    ['ltd_little_seoul'] = { nazwa = 'LTD Little Seoul', typ = 'spozywczy', pozycja = vector4(-706.06, -914.91, 19.21, 90.0) },
    ['elektroniczny'] = { nazwa = 'Elektroniczny', typ = 'elektroniczny', pozycja = vector4(-1083.2971, -245.8376, 37.7632, 207.0312) },

    -- Sklepy monopolowe zachowane z nowego configu
    ['liquor_vespucci'] = { nazwa = 'Rob’s Liquor Vespucci', typ = 'monopolowy', pozycja = vector4(-1221.37, -907.90, 12.33, 34.0) },
    ['liquor_morningwood'] = { nazwa = 'Rob’s Liquor Morningwood', typ = 'monopolowy', pozycja = vector4(-1486.63, -377.65, 40.16, 132.0) },
},
}
