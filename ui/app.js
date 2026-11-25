'use strict';
const $ = id => document.getElementById(id);
const el = (tag, cls, text) => { const n = document.createElement(tag); if (cls) n.className = cls; if (text !== undefined) n.textContent = text; return n; };
const paths = {
  box: 'M3 7 12 2l9 5v10l-9 5-9-5z M3 7l9 5 9-5 M12 12v10',
  drink: 'M6 8h12l-2 13H8z M5 8h14 M12 8l2-5 4-1',
  food: 'M3 10a9 7 0 0 1 18 0z M3 14h18 M4 17h16v1a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3z',
  basket: 'M3 10h18l-2 10H5z M7 10l4-7 M17 10l-4-7 M9 14v3 M15 14v3',
  search: 'M20 20l-4-4 M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0z',
  close: 'M6 6l12 12 M18 6 6 18', plus: 'M12 5v14 M5 12h14', minus: 'M5 12h14',
  card: 'M3 5h18v14H3z M3 10h18 M6 15h3',
  cash: 'M2 6h20v12H2z M5 12h1 M18 12h1 M14 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0z',
  check: 'M5 12l4 4L19 6', grid: 'M3 3h7v7H3z M14 3h7v7h-7z M3 14h7v7H3z M14 14h7v7h-7z',
};
function icon(name) {
  const ns = 'http://www.w3.org/2000/svg', svg = document.createElementNS(ns, 'svg'), path = document.createElementNS(ns, 'path');
  for (const [k,v] of Object.entries({viewBox:'0 0 24 24', fill:'none',stroke:'currentColor','stroke-width':'1.7','stroke-linecap':'round','stroke-linejoin':'round','aria-hidden':'true'})) svg.setAttribute(k,v);
  path.setAttribute('d', Object.hasOwn(paths, name) ? paths[name] : paths.box); svg.append(path); return svg;
}
function button(cls, glyph, label, action, compact = false) {
  const b = el('button', cls); b.type = 'button'; b.append(icon(glyph)); b.title = label; b.setAttribute('aria-label', label);
  if (!compact) b.append(document.createTextNode(label)); b.addEventListener('click', action); return b;
}
let sklep = null, kategoria = '', metoda = 'gotowka', koszyk = new Map(), zajety = false, sesja = 0;
const usd = n => '$' + new Intl.NumberFormat('pl-PL').format(n);
const norm = s => s.toLocaleLowerCase('pl').replaceAll('ł','l').normalize('NFD').replace(/[\u0300-\u036f]/g,'');
function obraz(p) {
  const a = el('div', 'art');
  const fallback = () => a.replaceChildren(icon(sklep?.kategorie?.[p.kategoria]?.ikona || 'box'));
  if (typeof p.obraz !== 'string' || !/^https:\/\//i.test(p.obraz)) { fallback(); return a; }
  const img = el('img'); img.alt = ''; img.draggable = false; img.addEventListener('error', fallback, {once:true}); a.append(img); img.src = p.obraz; return a;
}
function max(p) { return Math.min(sklep.limitSztuk, p.stan ?? Infinity); }
function zmien(p, delta) {
  if (zajety) return;
  const bylo = koszyk.get(p.id) || 0;
  if (delta > 0 && !bylo && koszyk.size >= sklep.limitPozycji) return;
  const ile = Math.min(max(p), bylo + delta);
  if (ile > 0) koszyk.set(p.id, ile); else koszyk.delete(p.id);
  status(''); render();
}
function status(tekst, blad = false) { $('status').textContent = tekst; $('status').dataset.error = blad; }
function render() {
  if (!sklep) return;
  const lista = Array.isArray(sklep.produkty) ? sklep.produkty : [];
  const kat = sklep.kategorie || {};
  const nav = $('kategorie'); nav.replaceChildren();
  const zakladki = [['', {etykieta:'Wszystkie',ikona:'grid'}], ...Object.entries(kat).filter(([id]) => lista.some(p => p.kategoria === id))];
  for (const [id, c] of zakladki) {
    const b = button('nav-btn', c.ikona, c.etykieta, () => { kategoria = id; render(); });
    b.setAttribute('aria-pressed', id === kategoria); nav.append(b);
  }
  $('sekcja').textContent = kat[kategoria]?.etykieta || 'Wszystkie produkty';
  const fraza = norm($('szukaj').value.trim());
  const produkty = lista.filter(p => (!kategoria || p.kategoria === kategoria) && norm(p.nazwa).includes(fraza));
  $('wyniki').textContent = `Liczba produktów: ${produkty.length}`;
  const grid = $('produkty'); grid.replaceChildren();
  if (!produkty.length) grid.append(el('p','empty','Brak produktów pasujących do wyszukiwania.'));
  for (const p of produkty) {
    const karta = el('article','product'), dol = el('div','product-bottom');
    const dodaj = button('add','plus','Dodaj: '+p.nazwa,() => zmien(p,1),true);
    dodaj.disabled = zajety || (koszyk.get(p.id) || 0) >= max(p) || (!koszyk.has(p.id) && koszyk.size >= sklep.limitPozycji);
    dol.append(el('strong','price',usd(p.cena)),dodaj);
    karta.append(obraz(p),el('h3',null,p.nazwa),el('span','muted',p.stan === 0 ? 'Wyprzedane' : p.stan == null ? 'Dostępne' : `W magazynie: ${p.stan}`),dol); grid.append(karta);
  }
  const lines = $('koszyk'); lines.replaceChildren();
  let total = 0, sztuk = 0;
  for (const [id, ile] of koszyk) {
    const p = lista.find(x => x.id === id); if (!p) continue;
    total += p.cena*ile; sztuk += ile;
    const w = el('div','line'), detale = el('div'), qty = el('div','qty');
    const minus = button('step','minus','Usuń jedną sztukę: '+p.nazwa,() => zmien(p,-1),true);
    const plus = button('step','plus','Dodaj jedną sztukę: '+p.nazwa,() => zmien(p,1),true);
    minus.disabled = zajety; plus.disabled = zajety || ile >= max(p);
    qty.append(minus,el('span',null,ile),plus); detale.append(el('strong',null,p.nazwa),el('span','muted',usd(p.cena*ile)));
    w.append(obraz(p),detale,qty); lines.append(w);
  }
  if (!sztuk) lines.append(el('p','empty','Koszyk jest pusty. Dodaj produkt, aby przejść do płatności.'));
  $('licznik').textContent = `Sztuk: ${sztuk}`; $('suma').textContent = usd(total);
  $('metody').replaceChildren(...[['gotowka','cash','Gotówka'],['karta','card','Karta']].map(([id,glyph,label]) => {
    const b = button('payment',glyph,label,() => { metoda = id; status(''); render(); });
    b.setAttribute('aria-pressed', id === metoda); b.disabled = zajety; return b;
  }));
  $('kup').disabled = zajety || sztuk === 0;
  $('kup').replaceChildren(icon('check'),document.createTextNode(zajety ? 'Przetwarzanie…' : 'Zrealizuj zakup'));
}
async function nui(akcja, dane = {}) {
  const res = await fetch(`https://${GetParentResourceName()}/${akcja}`, {method:'POST', headers:{'Content-Type':'application/json; charset=UTF-8'}, body:JSON.stringify(dane)});
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}
$('kup').onclick = async () => {
  if (!sklep || zajety || !koszyk.size) return;
  const numer = sesja; zajety = true; status(''); render();
  try {
    const r = await nui('kup',{metoda,koszyk:[...koszyk].map(([id,ilosc]) => ({id,ilosc}))});
    if (numer !== sesja) return;
    if (r.ok) for (const {id,ilosc} of r.wydane || []) {
      const pozostalo = (koszyk.get(id) || 0) - ilosc;
      if (pozostalo > 0) koszyk.set(id,pozostalo); else koszyk.delete(id);
    }
    if (r.sklep) {
      sklep = r.sklep;
      for (const [id, n] of koszyk) {
        const p = (sklep.produkty || []).find(x => x.id === id), limit = p ? max(p) : 0;
        if (limit <= 0) koszyk.delete(id); else if (n > limit) koszyk.set(id,limit);
      }
    }
    status(r.tekst || 'Brak odpowiedzi sklepu.', !r.ok || r.czesciowo);
  } catch { if (numer === sesja) status('Brak odpowiedzi. Sprawdź saldo i ekwipunek przed ponowieniem.',true); }
  finally { if (numer === sesja) { zajety = false; render(); } }
};
$('zamknij').append(icon('close'));
$('zamknij').onclick = () => nui('zamknij').catch(() => status('Nie udało się zamknąć. Użyj /zamknijsklep.',true));
$('lupa').append(icon('search')); $('kosz-ikona').append(icon('basket'));
$('szukaj').addEventListener('input',render);
function ukryjPanel() {
  sesja++; $('panel').hidden = true; sklep = null;
}
window.addEventListener('message', async ({data}) => {
  if (data?.typ === 'zamknij') { ukryjPanel(); return; }
  if (data?.typ !== 'otworz' || !data.sklep) return;
  const aktualna = ++sesja;
  $('panel').hidden = true;
  try {
    sklep = data.sklep; kategoria = ''; metoda = 'gotowka'; koszyk.clear(); zajety = false;
    $('nazwa').textContent = sklep.nazwa; $('szukaj').value = ''; status(''); render();
    $('panel').hidden = false;
    const r = await nui('pokazano', {numer: data.numer});
    if (!r.ok && aktualna === sesja) ukryjPanel();
  } catch (blad) {
    if (aktualna === sesja) ukryjPanel();
    console.error('[Project Nashville — Sklepy] Nie udało się otworzyć panelu:', blad);
  }
});
