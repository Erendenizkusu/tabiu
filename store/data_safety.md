# Play Console — Data Safety (Veri Güvenliği) Formu Cevapları

Play Console → App content → **Data safety** bölümünde aşağıdaki gibi doldur.

## Genel sorular
- **Uygulaman kullanıcı verisi topluyor veya paylaşıyor mu?** → **Evet** (Yes)
- **Aktarımda tüm veriler şifreleniyor mu?** → **Evet** (Firebase ve AdMob HTTPS/TLS kullanır)
- **Kullanıcılar verilerinin silinmesini talep edebiliyor mu?** → **Evet**
  (Gizlilik politikasındaki e-posta ile). İstersen "No" da seçilebilir ama
  "Evet" + iletişim e-postası en temizi.

## Toplanan veri türleri (işaretlenecekler)

### 1) Personal info → **Name (İsim)**
- Toplanıyor mu? **Evet**
- Paylaşılıyor mu? **Hayır** (yalnızca oyun içi diğer oyunculara gösterilir,
  üçüncü tarafa satılmaz)
- İsteğe bağlı mı? **Kullanıcı tarafından girilen** (opsiyonel takma ad)
- Amaç: **App functionality** (oyun işlevi)
> Gerekçe: Oyuncu odaya katılırken bir takma ad giriyor; bu ad Firestore'da
> saklanıp diğer oyunculara gösteriliyor.

### 2) Device or other IDs → **Device or other IDs**
- Toplanıyor mu? **Evet**
- Paylaşılıyor mu? **Evet** (AdMob reklam ortağıyla)
- Amaç: **Advertising or marketing**, **Analytics**
> Gerekçe: Google AdMob reklam kimliğini (Advertising ID) kullanır.

### 3) App activity (opsiyonel ama önerilir) → **App interactions**
- Toplanıyor mu? **Evet**
- Paylaşılıyor mu? **Evet** (AdMob)
- Amaç: **Advertising or marketing**, **Analytics**

### 4) App info and performance → **Crash logs**, **Diagnostics** (opsiyonel)
- AdMob/Firebase SDK'ları temel tanılama verisi işleyebilir. İşaretlemek
  güvenli taraftır.
- Amaç: **App functionality**, **Analytics**

## İşaretlenMEyecekler
- Konum (precise/approximate) — biz doğrudan toplamıyoruz. *(AdMob yaklaşık
  konum çıkarımı yapabilir; şüphedeysen "Approximate location → Advertising"
  işaretleyebilirsin, ama zorunlu değil.)*
- Kişiler, fotoğraf, mesaj, sağlık, finans, dosyalar → **Hayır**

## Reklam beyanı (ayrı bölüm)
- App content → **Ads** → "Bu uygulama reklam içeriyor mu?" → **Evet**
- Target audience → **13 yaş ve üstü** (reklam politikası ve çocuk gizliliği
  için en temiz seçim; "Designed for Families" programına girmiyoruz)
