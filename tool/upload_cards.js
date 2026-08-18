// Tabiu — bulk uploader for tool/new_cards.json into Firestore `cards`.
//
// Reads new_cards.json ({main, forbidden[]}), signs in anonymously with the
// project's web API key, and writes every card via the Firestore :commit
// batch endpoint (client-generated 20-char IDs, matching Firestore auto-IDs).
//
// Run:  node tool/upload_cards.js
// Requires the `cards` collection to be temporarily writable by authenticated
// users (see the rules snippet shared in chat). Revert rules afterwards.

const fs = require('fs');
const https = require('https');

const KEY = "AIzaSyD6isHc3jj1UVHd3mdZ59AjJdKA0oNH0Ao";
const PROJ = "tabiu-f4f04";
const CARDS = JSON.parse(fs.readFileSync(__dirname + "/new_cards.json", "utf8"));

function req(opts, body) {
  return new Promise((res, rej) => {
    const r = https.request(opts, (resp) => {
      let d = ''; resp.on('data', c => d += c);
      resp.on('end', () => res({ status: resp.statusCode, body: d }));
    });
    r.on('error', rej);
    if (body) r.write(body);
    r.end();
  });
}

const ID_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
function autoId() {
  let s = "";
  for (let i = 0; i < 20; i++) s += ID_CHARS[Math.floor(Math.random() * ID_CHARS.length)];
  return s;
}

function toFields(card) {
  return {
    main: { stringValue: card.main.toLocaleUpperCase('tr') },
    forbidden: {
      arrayValue: { values: card.forbidden.map(w => ({ stringValue: w })) }
    }
  };
}

async function currentCount(token) {
  // structured query aggregation would be ideal; simple list count is enough
  let count = 0, pageToken = '';
  do {
    let path = `/v1/projects/${PROJ}/databases/(default)/documents/cards?pageSize=300&mask.fieldPaths=main`;
    if (pageToken) path += `&pageToken=${encodeURIComponent(pageToken)}`;
    const r = await req({ hostname: 'firestore.googleapis.com', path, method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` } });
    const j = JSON.parse(r.body);
    count += (j.documents || []).length;
    pageToken = j.nextPageToken || '';
  } while (pageToken);
  return count;
}

(async () => {
  // anonymous sign-in
  const s = await req({ hostname: 'identitytoolkit.googleapis.com',
    path: `/v1/accounts:signUp?key=${KEY}`, method: 'POST',
    headers: { 'Content-Type': 'application/json' } },
    JSON.stringify({ returnSecureToken: true }));
  const token = JSON.parse(s.body).idToken;
  if (!token) { console.error("Sign-in failed:", s.body); process.exit(1); }

  const before = await currentCount(token);
  console.log(`Yüklemeden önce mevcut kart sayısı: ${before}`);
  console.log(`Yüklenecek yeni kart: ${CARDS.length}`);

  const BATCH = 200;
  let written = 0;
  for (let i = 0; i < CARDS.length; i += BATCH) {
    const chunk = CARDS.slice(i, i + BATCH);
    const writes = chunk.map(card => ({
      update: {
        name: `projects/${PROJ}/databases/(default)/documents/cards/${autoId()}`,
        fields: toFields(card)
      }
    }));
    const r = await req({ hostname: 'firestore.googleapis.com',
      path: `/v1/projects/${PROJ}/databases/(default)/documents:commit`,
      method: 'POST', headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' } },
      JSON.stringify({ writes }));
    if (r.status !== 200) {
      console.error(`Batch ${i / BATCH + 1} HATA (status ${r.status}):`, r.body.slice(0, 500));
      console.error("Kural yazma izni kapalı olabilir. İş yarım kaldı; kuralları açıp tekrar çalıştırma DUPLİKE yaratır — bana haber ver.");
      process.exit(1);
    }
    written += chunk.length;
    console.log(`  ✔ batch ${Math.floor(i / BATCH) + 1}: +${chunk.length} (toplam ${written}/${CARDS.length})`);
  }

  const after = await currentCount(token);
  console.log(`\nYüklendi. Yeni kart sayısı: ${after} (öncesi ${before}, fark ${after - before})`);
})();
