# Tabiu — App Store Connect Mağaza Metinleri

App Store Connect → My Apps → (+) New App ile uygulamayı oluştururken ve
"App Information" / "Version Information" bölümlerini doldururken kullan.

## Uygulama oluşturma (New App)
- **Platform:** iOS
- **Name:** `Tabiu`  (App Store'da görünen ad, max 30 karakter)
- **Primary Language:** Turkish (Türkçe)
- **Bundle ID:** `com.tabiu.tabiu`  (Developer portalında App ID olarak kayıtlı olmalı)
- **SKU:** `tabiu-ios-001`  (dahili takip kodu, kullanıcıya görünmez, serbest)
- **User Access:** Full Access

---

## App Information (dile göre)

### Subtitle (max 30 karakter)
```
Gerçek zamanlı tabu oyunu
```

### Kategori
- **Primary:** Games → **Word**  (alternatif: Trivia)
- **Secondary (opsiyonel):** Games → **Family** veya **Casual**

### Privacy Policy URL (zorunlu)
```
https://erendenizkusu.github.io/tabiu/
```

---

## Version Information (1.0)

### Promotional Text (max 170 karakter — sürüm göndermeden istediğin an güncellenebilir)
```
Arkadaşlarınla gerçek zamanlı oyna! Oda kur, kodu paylaş, yasaklı kelimelere
değmeden anlat ve takımını zafere taşı. 🎉
```

### Description (max 4000 karakter)
```
Tabiu, arkadaşlarınla aynı odada ya da uzaktan oynayabileceğin gerçek zamanlı
bir kelime anlatma oyunudur! Bir kelimeyi, ekrandaki yasaklı kelimeleri
kullanmadan takım arkadaşlarına anlat; onlar bildikçe puanları topla.

🎉 NASIL OYNANIR?
• Bir oda kur, arkadaşların oda koduyla katılsın.
• İki takıma ayrılın: Kırmızı ve Mavi.
• Sıra sendeyken kelimeyi anlat — ama altındaki yasaklı kelimeleri SÖYLEME!
• Doğru bilinen her kelime takımına puan kazandırır.
• Süre bitince sıra diğer takıma geçer. En çok puanı toplayan takım kazanır!

✨ ÖZELLİKLER
• Gerçek zamanlı çok oyunculu: Herkes aynı oyunu anında görür.
• Oda kur & katıl: Tek dokunuşla oda kodu paylaş.
• Kırmızı vs Mavi takım rekabeti.
• Şık, akıcı ve modern arayüz.
• Kazananı kutlayan konfetili sonuç ekranı.
• Ücretsiz oyna.

Partiler, aile geceleri, arkadaş buluşmaları ve mola aralarının vazgeçilmezi.
Hadi odanı kur ve Tabiu'da takımını zafere taşı!
```

### Keywords (max 100 karakter, virgülle ayır, aralara boşluk koyma — boşluk karakter yer)
```
tabu,kelime oyunu,parti oyunu,çok oyunculu,takım,arkadaş,anlatma,tahmin,kelime
```

### Support URL (zorunlu)
```
https://erendenizkusu.github.io/tabiu/
```
> Not: Ayrı bir destek sayfan yoksa gizlilik politikası sayfası kabul edilir.
> İstersen veri silme sayfasını da kullanabilirsin:
> https://erendenizkusu.github.io/tabiu/data-deletion.html

### Marketing URL (opsiyonel)
```
(boş bırakılabilir)
```

### Copyright
```
2026 Tabiu
```

---

## Age Rating (yaş derecelendirme anketi)
- Anketi dürüstçe doldur; oyunda şiddet/müstehcen içerik yok.
- Reklam içerdiği için beklenen sonuç: **4+** veya **9+** (App Store'da reklam
  tek başına yaşı yükseltmez). Play tarafında 13+ dedik; iOS anketi ayrı çalışır.

## Pricing
- **Price:** Free (Ücretsiz)
- **Availability:** Tüm ülkeler (veya istediğin ülkeler)

---

## App Privacy ("Nutrition Label" — App Store'un veri beyanı)
Play'deki Data Safety'nin iOS karşılığı. App Store Connect → App Privacy.

**"Do you collect data from this app?"** → **Yes**

Toplanan veri türleri:

| Veri | Linked to user? | Used for tracking? | Amaç |
|---|---|---|---|
| **Name** (takma ad) | Evet | Hayır | App Functionality |
| **Device ID** (IDFA — AdMob) | Evet | **Evet** | Third-Party Advertising |
| **Product Interaction** (App interactions) | Evet | Evet | Advertising, Analytics |
| **Crash Data / Diagnostics** | Hayır | Hayır | App Functionality, Analytics |

> "Used for tracking = Evet" işaretlediğin veriler için **App Tracking
> Transparency (ATT)** izni gerekir — aşağıdaki Info.plist notuna bak.

---

## ⚠️ Mac ile build almadan ÖNCE tamamlanması gerekenler (kod tarafı)

### 1) iOS AdMob App ID — ✅ TAMAMLANDI
`ios/Runner/Info.plist` içine eklendi:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-2707472203466324~3625305801</string>
```
> iOS interstitial reklam birimi zaten kodda var (lib/core/ads.dart →
> ca-app-pub-2707472203466324/8630934489).

### 2) App Tracking Transparency — ✅ TAMAMLANDI
`ios/Runner/Info.plist` içine eklendi:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>Sana daha alakalı reklamlar göstermek için kullanılır.</string>
```

### 3) Ekran görüntüleri (App Store için zorunlu)
- **6.9" iPhone** (1320×2868) veya **6.7" iPhone** (1290×2796) — en az 1, tercihen 3-5 adet.
- Simülatörden alınabilir (Mac'te). Play için de eksikti; ikisi için ortak çekelim.

---

## İletişim
denizkusueren61@gmail.com
