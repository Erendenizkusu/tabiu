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
