# Tabiu — Kapalı Test Notları & Üretim Başvurusu Hazırlığı

> Bu dosya, Google Play "Üretime başvur" adımında sorulan sorulara (testçiler
> nasıl bulundu, geri bildirimler neydi, ne değiştirdin?) hazır cevap vermek
> için tutuluyor. 14 günlük kapalı test dolduğunda buradan kopyala-yapıştır
> yapılabilir. Tarih formatı: YYYY-AA-GG.

---

## 1. Kapalı testi nasıl yürüttük? (kopyala-yapıştır)

Uygulamayı, yakın çevremden (aile ve arkadaşlar) davet ettiğim en az 12 gerçek
test kullanıcısıyla kapalı test kanalında paylaştım. Testçiler uygulamayı kendi
Android cihazlarına kurdu, gerçek zamanlı çok oyunculu Tabu oyununu birlikte
(aynı odada ve uzaktan) oynadı ve deneyimlerini bana doğrudan iletti. Test
boyunca oda kurma, katılma, tur akışı, skorlama ve kelime çeşitliliği gibi tüm
temel akışları düzenli olarak denedik.

## 2. Testçilerden gelen geri bildirimler ve yaptığımız düzeltmeler (kopyala-yapıştır)

Test sürecinde aldığım başlıca geri bildirimler ve bunlara karşılık yaptığım
iyileştirmeler:

- **Kelime havuzu küçüktü, aynı kelimeler sık tekrar ediyordu.** Kelime
  bankasını büyük ölçüde genişlettim (110 karttan 746 karta çıkardım; ~24 farklı
  kategori — mutfak, hayvanlar, meslekler, filmler, ünlü kişiler, bilim vb.).
- **Yeni odalarda önceki oyunlardaki kelimeler tekrar geliyordu.** Cihaz bazlı
  bir "son görülen kelimeler" hafızası ekledim; yeni oda açıldığında son
  oyunlarda çıkan kelimeler atlanıyor ve oyuncular her oyunda daha taze
  kelimelerle karşılaşıyor.
- **Kart bazı telefonlarda ekrana tam sığmıyordu.** Oyun kartını ve arayüzü
  tüm ekran boyutlarına duyarlı (responsive) hale getirdim; küçük ekranlarda da
  kart ve butonlar düzgün görünüyor.
- **Biri masadan kalkınca tur devam ediyordu.** Anlatıcının turu
  duraklatıp/devam ettirebilmesi için bir duraklatma özelliği ekledim; süre
  donuyor ve tüm oyunculara senkron yansıyor.
- **Kararlılık ve genel cila:** Açılışta yaşanan bir çökme giderildi; skor,
  haptik/ses geri bildirimleri ve genel arayüz akıcılığı iyileştirildi.

## 3. Uygulamanın mevcut durumu (kopyala-yapıştır)

Uygulama kararlı ve yayına hazır durumda. Temel özellikler — oda oluşturma/
katılma, gerçek zamanlı çok oyunculu oynanış, takım skorlaması, tur/süre yönetimi
ve geniş kelime bankası — sorunsuz çalışıyor. Test kullanıcılarından gelen
geri bildirimlerin tamamı sürüm güncellemeleriyle karşılandı.

---

## Değişiklik günlüğü (teknik, kendim için)

Sürüm: **1.0.1 (build 5)** — pubspec `version: 1.0.1+5`.

### 2026-08 — Kapalı test döneminde yapılanlar
- Kelime bankası 110 → **746 kart** (636 yeni kart, ~24 kategori). Kaynak:
  `tool/new_cards.json`, yükleyici: `tool/upload_cards.js`. Her kart = ana kelime
  + 5 yasaklı kelime (yüksek zorluk).
- Firestore `cards` koleksiyonu istemciye **salt-okunur** kilitlendi (yazma yok;
  yalnızca konsol/script). Diğer güvenlik kurallarıyla birlikte.
- **Kart tekrarı düzeltmesi:** Cihaz-yerel "son görülen kartlar" hafızası
  (`lib/data/seen_cards.dart`, `SeenCardsStore`). Yeni oda kurulurken
  `usedCardIds` bu hafızayla tohumlanıyor (`createRoom`), her cihaz gördüğü
  çiftleri kaydediyor (`game_screen._recordSeenPair`). Bankada her zaman ≥300
  kart taze kalıyor, oyun-içi tekrar yok.
- Responsive oyun kartı + tur duraklatma (önceki commit'ler).
- iOS: `ITSAppUsesNonExemptEncryption=false` (Info.plist), 13" iPad mağaza
  görselleri (`tool/gen_ipad_screenshots.dart`).

### Bekleyen / sonraki adımlar
- Android: 14 günlük kapalı test dolunca **Üretime başvur** → Production'a terfi.
- iOS: App Store incelemesi (lisans sözleşmesi onaylandı, kuyrukta).
- Üretim öncesi R8'i keep kurallarıyla tekrar aç (boyut ~19MB → ~12MB).
