# Tabiu — Yol Haritası (Sıradaki İşler)

Tabiu, Flutter + Firebase ile yazılmış gerçek zamanlı çok oyunculu Tabu (Taboo) oyunudur.
Bu dosya, MVP kabul edildikten sonra kalan işleri takip eder.

## Mevcut Durum (Kabul edilen MVP)
- ✅ Tüm akış çalışıyor: Oda Kur → Bekleme Alanı → Odaya Katıl → Oyun → Round Bitti → Sonuç.
- ✅ Gerçek zamanlı çok oyunculu (Firestore stream), anonim auth ("Oyuncu ID").
- ✅ Kart mekaniği: her el 2 kart (ön/arka), Doğru +1 / 2x Doğru +2 / Tabu −1 / Pas.
- ✅ `usedCardIds` oda ömrü + rövanş boyunca birikiyor (kelime tekrarı önleniyor).
- ✅ Oda temizliği: `expireAt` alanı + host çıkınca batch delete + kurulumda lazy sweep.
- ✅ Görsel kimlik: "Mor Parti" (derin menekşe premium, grain'li atmosfer, oyuncu balon logo,
  parlak lavanta cam butonlar, dikey premium kart, eski düzen bilgi paneli).
- ✅ AdMob interstitial: sonuç ekranında, oyun bitince tek reklam (round aralarında/lobide yok).
  Android App ID + gerçek Ad Unit ID bağlı (`lib/core/ads.dart`). iOS ID'leri de kodda hazır ama
  proje henüz iOS platformuna eklenmedi — eklenince `ios/Runner/Info.plist`'e
  `GADApplicationIdentifier` (ca-app-pub-2707472203466324~3625305801) girilmeli.
- ✅ Bağlantısız açılış ve ağ hatası senaryoları: internet olmadan ilk açılışta (`main.dart`)
  artık sonsuz boş ekran yerine "Bağlantı kurulamadı" + Tekrar Dene ekranı geliyor; oda
  kurma/katılma/rövanş/devam gibi tüm aksiyonlar hata mesajını SnackBar ile gösteriyor; round
  süresi bitince yaşanan geçici Firestore hatası artık round'u sonsuza kadar kilitlemiyor
  (otomatik tekrar deniyor).

---

## Sıradaki İşler

### 1. Animasyonları premium seviyeye çıkar
Şu an temel animasyonlar var ama daha zengin/akıcı olmalı.
- **+1 / +2 baloncuğu**: mevcut düz baloncuk yerine glow + küçük parçacık/ışık patlaması, daha
  tatmin edici bir "pop". Yeşil için +1/+2, Tabu için kırmızı hata efekti + ekran/kart sarsıntısı.
- **Kart çevirme**: flip'i daha akıcı ve "ağırlıklı" hisset (ease, hafif ölçek/gölge değişimi).
- **Timer**: son 10 sn'de nabız atması + renk geçişi (halka yok artık; "Süre" metni kırmızıya dönüyor,
  buna hafif titreşim/nabız eklenebilir).
- **Ekran geçişleri**: shared-axis / hero geçişleri, kart girişte hafif "deal" animasyonu.
- **Skor kutuları**: puan değişince sayı sayacı + kısa vurgu (şu an TweenAnimationBuilder var, zenginleştir).

### 2. Gerçek kaliteli ses efektleri
Şu anki sesler çalışma anında sentezlenen WAV bip'leri — cılız/ucuz. Değiştirilecek.
- Gerçek, tatmin edici ses dosyaları göm (`assets/sounds/`): doğru (yumuşak pop), 2x doğru (yükselen),
  tabu (buzzer), süre bitti, kazanma (konfeti/fanfar), buton tık.
- CC0 / royalty-free kaynaklardan bul veya kaliteli sentezle. `audioplayers` ile çal, `core/sfx.dart`
  içindeki sentezleyiciyi dosya tabanlıya çevir. Ses aç/kapa zaten var.
- Haptik ile senkron (başarı, hata, kutlama desenleri `core/haptics.dart`'ta hazır).

### 3. Mola (timeout) özelliği
Oyun sırasında turu duraklatma.
- Round timer'ı durdur/sürdür; tüm istemcilerde senkron (Firestore'da `turnState`'e `pausedAt` /
  kalan süre yaz, `endsAt`'i devam edince yeniden hesapla).
- Host veya anlatıcı tetikler; oyun ekranına "Mola" butonu, molada overlay + "Devam" butonu.

### 4. AdMob — mağazaya çıkmadan önce kalanlar
- **UMP / reklam izni akışı** henüz eklenmedi. AB/EEA + İngiltere'de reklam göstermek için Google'ın
  User Messaging Platform (rıza formu) entegrasyonu şart — `google_mobile_ads` bunu destekliyor,
  ayrıca bir `google_mobile_ads` UMP kurulumu gerekiyor. Sadece TR hedefleniyorsa öncelik daha düşük,
  ama mağaza incelemesi öncesi netleştirilmeli.
- iOS platformu projeye eklendiğinde `Info.plist`'e `GADApplicationIdentifier` + `NSUserTrackingUsageDescription`
  (ATT — App Tracking Transparency) eklenmeli.

---

## İleride (v2+)

### Kart paketi / kategori satın alma
Şu an `cards.category` alanı anlamsız placeholder harfler taşıyor, kullanılmıyor
(bkz. Kurulum notları). İleride:
- Gerçek kategoriler tanımlanıp kart havuzu kategoriye göre etiketlenecek.
- Ücretsiz temel paket + satın alınabilir ek kart paketleri (in-app purchase).
- Oda kurarken kategori/paket filtresi seçilebilecek.

---

## Kurulum / Bakım Notları
- **Firestore TTL**: Firebase Console → Firestore → TTL policy, koleksiyon `rooms`, alan `expireAt`
  olarak AÇILMALI. Terk edilmiş odaları otomatik siler (Cloud Functions gerektirmez).
- **Firebase projesi**: `tabiu-f4f04`. Anonim auth açık. `flutterfire configure` ile bağlandı.
- **Hedef platformlar**: Android (birincil) + Web (test). Windows masaüstü için Visual Studio gerekiyor.
- **Kategoriler**: `cards.category` alanı anlamsız placeholder harfler; şu an kullanılmıyor. İleride
  gerçek kategori mantığı gelirse filtre eklenebilir (model zaten `category`'yi taşıyor).

## Küçük İyileştirmeler (opsiyonel)
- Pas butonu renk uyumu (şu an altın; lavantaya çekilebilir).
- Bilgi paneli/cam yüzeylerde biraz daha derinlik.
- Sonuç ekranında kazanan oyuncu/MVP vurgusu (şu an takım bazlı).
