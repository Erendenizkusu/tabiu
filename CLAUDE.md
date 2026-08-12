# Tabiu — Proje Notları

Flutter + Firebase gerçek zamanlı Tabu oyunu (Firebase projesi: `tabiu-f4f04`).

## Çalışma kuralları

- **Tasarım isteklerinde `artifact-design` skill'ini kullan.** Kullanıcı benden
  herhangi bir tasarım (ikon, logo, mağaza görseli, arayüz taslağı, seçenek
  galerisi vb.) istediğinde önce `artifact-design` skill'ini yükleyip ona göre
  üret. İkon/logo seçeneklerini kullanıcıya **Artifact (web sayfası) linki**
  olarak sun; kullanıcı tarayıcıdan inceleyip seçer.
- UI tarafı kritik; son sözü kullanıcı verir.
- Uygulama dili Türkçe; kullanıcıyla Türkçe konuş.

## Marka kimliği

- "Mor Parti" kimliği: derin mor zemin (`#3A1B6E → #160A2E`), pembe→magenta
  aksan (`#C46BFF → #FF4FB8`), lavanta yüzeyler. Renk token'ları:
  `lib/app/palette.dart`.
- Uygulama ikonu: pembe kart destesi + beyaz **T** monogramı, mor zemin üzerinde.
- İkonlar `tool/gen_icon.dart` (final) ve `tool/gen_icon_options.dart`
  (seçenekler) ile `flutter test` üzerinden vektörel çizilir; font bağımlılığı
  yoktur. `dart run flutter_launcher_icons` ile tüm yoğunluklara uygulanır.

## Release / mağaza

- Release imzalama `android/key.properties` üzerinden (gitignored; keystore
  `C:/Users/User/keystores/tabiu-upload.jks`). Fresh clone'da debug key'e düşer.
- Mağaza materyalleri: `store/` (gizlilik politikası, açıklamalar, data safety)
  ve `tool/play_store_icon.png`, `tool/play_feature_graphic.png`.
- AdMob geçiş reklamı `lib/core/ads.dart` — oyun bitiminde sonuç ekranında bir
  kez gösterilir.
