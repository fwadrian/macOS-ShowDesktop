# ShowDesktop

ShowDesktop macOS işletim sistemlerinde masaüstüne kolay geçişi hedeflemiş, son derece hafif çalışan ve tek tık ile tüm uygulamaları minimize etmenizi sağlayan yardımcınızdır. ShowDesktop, macOS'ta açık uygulama pencerelerini tek tıklama veya `⌥ Space` kısayoluyla Dock'a küçültür. İkinci kullanımda yalnızca ShowDesktop'un küçülttüğü pencereleri geri getirir. Üstelik bunu yaparken istediğiniz uygulamanın ekranda kalmasını da sağlayabilir.

## Gereksinimler

- macOS 13 veya üzeri
- Hazır 0.1.1 paketi için Apple Silicon (arm64) Mac
- Kaynaktan derlemek için Xcode 15 veya üzeri
- Pencere yönetimi için Accessibility izni

## Sürüm durumu

0.1.1, erken erişim sürümüdür. Temel küçült/geri getir, kısayol, önceden küçültülmüş pencerelerin korunması, Dock'tan elle açılmış pencere sonrası geri getirme ve kapatılan uygulama sonrası devam etme testleri geçti. Yanıt vermeyen uygulama ve geri getirme listesini sıfırlama akışlarının manuel doğrulaması bekliyor. Otomatik testler: 10 başarılı test.

## Kurulum

Yayınlanan DMG içindeki ShowDesktop uygulamasını Applications klasörüne taşıyın. Güncellemeden önce çalışan ShowDesktop'tan sağ tık menüsüyle çıkın; ardından Applications içindeki yeni sürümü açın. Erişilebilirlik izni gerektiğinde Sistem Ayarları > Gizlilik ve Güvenlik > Erişilebilirlik bölümünü kullanın.

## Gizlilik

Uygulamada hesap, reklam, analiz veya uygulama içi ağ isteği bulunmaz. Pencereleri yönetmek için macOS Accessibility API kullanılır. Hariç tutulan uygulamalar ve kısayol tercihi cihazdaki UserDefaults içinde saklanır. Hata günlükleri yerel sistem günlüğüne uygulama adı, bundle kimliği ve hata kodu yazabilir. Hata raporu paylaşırken kişisel bilgileri kaldırın.

## Bilinen sınırlar

- Tam ekran veya küçültmeyi desteklemeyen özel pencereler etkilenmeyebilir.
- ShowDesktop kapatılırsa geri getirme listesi kaybolur; pencereler Dock'tan açılabilir.
- İşlem devam ederken gelen yeni toggle istekleri yok sayılır.
- Geri getirme hatasında kayıtlar korunur. Tekrar tıklama yeniden dener; sağ tık menüsündeki liste sıfırlama seçeneği bu kayıtları açık onayla unutur.
- Hazır paket Apple Silicon içindir; Intel ve tüm desteklenen macOS sürümleri üzerinde doğrulama yapılmadı.
- Bu dağıtım Mac App Store yayını değildir.

## Geliştirme

Projeyi klonladıktan sonra `Package.swift` dosyasını Xcode ile açın. `ShowDesktop` hedefini ve `My Mac` cihazını seçip `⌘R` ile çalıştırın.

İlk çalıştırmada macOS, Sistem Ayarları > Gizlilik ve Güvenlik > Erişilebilirlik bölümünden izin vermenizi isteyebilir.

## Kullanım

- Menü çubuğu simgesine sol tıklayın: pencereleri küçültür veya geri getirir.
- `⌥ Space` kısayolunu kullanın.
- Sağ tıklayarak yönetim menüsünü açın.

Menüden uygulama hariç tutma, kısayol değiştirme ve girişte başlatma ayarları yapılabilir.

## Test

```sh
swift test
```

Gerçek pencere davranışı için [MANUAL-TEST-CHECKLIST.md](MANUAL-TEST-CHECKLIST.md) dosyasındaki senaryoları uygulayın.

## Release

Release uygulaması oluşturmak için Developer ID kimliğinizi ortam değişkeni olarak verin:

```sh
SHOWDESKTOP_SIGNING_IDENTITY="Developer ID Application: ..." \
SHOWDESKTOP_BUNDLE_IDENTIFIER="com.example.ShowDesktop" \
zsh Scripts/build-app.sh
```

İmzalama, notarization ve dağıtım adımları için [RELEASING.md](RELEASING.md) dosyasına bakın.

## Proje yapısı

- `Sources/ShowDesktop/`: uygulama kaynak kodu
- `Tests/ShowDesktopTests/`: otomatik testler
- `Resources/`: uygulama paket kaynakları ve ikon
- `Scripts/`: build ve release script'leri

## Lisans

Bu proje için henüz bir lisans seçilmedi. Lisans dosyası eklenene kadar kaynak kodun yeniden kullanımı veya dağıtımı için açık bir izin verilmiş sayılmaz.
