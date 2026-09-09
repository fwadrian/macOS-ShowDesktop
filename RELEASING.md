# Release Rehberi

Bu belge geliştiriciler içindir. Apple hesabı, sertifika veya parola bilgilerini
proje dosyalarına eklemeyin.

## Release uygulaması

Developer ID sertifikasının Keychain'de kurulu olduğunu doğrulayın:

```sh
security find-identity -v -p codesigning
```

Ardından kendi Developer ID kimliğinizi vererek imzalı uygulamayı oluşturun:

```sh
SHOWDESKTOP_SIGNING_IDENTITY="Developer ID Application: ..." \
SHOWDESKTOP_BUNDLE_IDENTIFIER="com.example.ShowDesktop" \
zsh Scripts/build-app.sh
```

Çıktı `dist/ShowDesktop.app` konumunda oluşur.

## Notarization profili

Apple ID için [appleid.apple.com](https://appleid.apple.com) üzerinden bir

Profil bilgilerini macOS Keychain'e kaydetmek için gerçek Apple ID ve Team ID
değerlerinizi kullanın:

```sh
xcrun notarytool store-credentials ShowDesktopNotary \
  --apple-id "APPLE_ID_ADRESINIZ" \
  --team-id "TEAM_ID"
```

Profil kaydedildikten sonra notarization script'ini çalıştırın:

```sh
zsh Scripts/notarize-app.sh
```

Script uygulamayı Apple'a gönderir, onay sonrası notarization ticket'ını ekler
ve Gatekeeper doğrulaması yapar.

## Test DMG'si

Notarization tamamlandıktan sonra notarized uygulamadan DMG oluşturun. DMG,
test kullanıcılarına doğrudan dağıtım için kullanılabilir; App Store yayını
anlamına gelmez.

## Kontrol listesi

- Release uygulaması gerçek Mac'te test edildi.
- Accessibility izni akışı kontrol edildi.
- `⌥ Space`, sağ tık menüsü ve hariç tutulan uygulamalar test edildi.
- Uygulama Developer ID ile imzalandı.
- Notarization sonucu `Accepted` oldu.
- `stapler validate` ve `spctl` kontrolleri başarılı oldu.
