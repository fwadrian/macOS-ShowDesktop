# ShowDesktop Manuel Test Kontrol Listesi

Bu testler imzalı veya Xcode üzerinden çalıştırılan macOS uygulamasıyla, en az
iki farklı uygulama açıkken gerçekleştirilmelidir.

## Ön Koşullar

- [ ] macOS 13 veya üzeri kullanılıyor.
- [ ] ShowDesktop çalışıyor ve menü çubuğu simgesi görünüyor.
- [ ] Finder, Safari veya Terminal gibi en az iki normal uygulama açık.
- [ ] Test sırasında daha önce kullanıcı tarafından küçültülen bir pencere not edildi.

## Accessibility İzni

- [ ] Accessibility izni kapalıyken toggle çalıştırılır.
- [ ] İzin uyarısı gösterilir.
- [ ] “Ayarları Aç” düğmesi doğru Sistem Ayarları sayfasını açar.
- [ ] İzin verildikten sonra toggle tekrar çalıştırıldığında pencereler küçülür.

## Temel Toggle

- [ ] Menü çubuğu simgesine sol tıklamak açık pencereleri Dock’a küçültür.
- [ ] İkinci sol tıklama yalnızca ShowDesktop’un küçülttüğü pencereleri geri getirir.
- [ ] `⌥ Space` aynı davranışı sol tıklamayla aynı şekilde gerçekleştirir.
- [ ] İşlem sonunda tooltip kaç pencerenin işlendiğini gösterir.

## Pencere Koruma

- [ ] Toggle öncesinde kullanıcı tarafından Dock’a küçültülmüş pencere geri getirilmez.
- [ ] Tam ekran pencere uygulamanın çökmesine veya işlem akışının bozulmasına neden olmaz.
- [ ] Küçültülemeyen özel pencere varsa diğer pencereler yine işlenir.
- [ ] Uygulama veya pencere restore işleminden önce kapanırsa uygulama çalışmaya devam eder.

## Hariç Tutulan Uygulamalar

- [ ] Sağ tık menüsünden “Hariç tutulan uygulamalar” alt menüsü açılır.
- [ ] Bir uygulama hariç tutulduğunda pencereleri küçültülmez.
- [ ] Hariç tutma kaldırıldığında uygulama sonraki toggle işlemine dahil edilir.
- [ ] ShowDesktop yeniden başlatıldıktan sonra hariç tutma seçimi korunur.

## Kısayol

- [ ] Menüden farklı bir kısayol seçilir ve yeni kısayol çalışır.
- [ ] Eski kısayolun artık çalışmadığı doğrulanır.
- [ ] ShowDesktop yeniden başlatıldıktan sonra seçilen kısayol korunur.
- [ ] Sistemle çakışan bir kısayol seçildiğinde hata loglanır ve önceki kısayol korunur.

## Login Sırasında Başlatma

- [ ] “Girişte başlat” menü seçeneği açılır.
- [ ] Seçenek işaretli durumunu doğru gösterir.
- [ ] Kullanıcı oturumu kapatıp açtıktan sonra ShowDesktop otomatik başlar.
- [ ] Seçenek kapatıldığında sonraki oturum açılışında uygulama başlamaz.

## Sonuç Kaydı

- Test tarihi:
- macOS sürümü:
- Uygulama sürümü/commit:
- Sonuç:
- Gözlemler ve hatalar:

## Gemini incelemesi sonrası regresyonlar (bekliyor)

- [ ] Sol tık ve seçili kısayol aynı küçült/geri getir davranışını çalıştırıyor.
- [ ] İşlem sürerken hızlı kısayol basışları yeni işlem kuyruğu oluşturmuyor; sağ tık menüsü yanıt veriyor.
- [x] Kullanıcının önceden küçülttüğü pencereler geri getirilmiyor. (0.1.1, kullanıcı doğruladı.)
- [ ] ShowDesktop'un küçülttüğü pencere Dock'tan elle açılırsa restore sayacında zaten açık olarak gösteriliyor.
- [ ] Kapatılan uygulama/pencere restore listesinden eleniyor.
- [ ] Yanıt vermeyen test uygulamasında ShowDesktop menüsü yanıt vermeye devam ediyor; timeout sonrası işlem tamamlanıyor.
- [ ] Restore hatasında yeniden tıklama tekrar deniyor; sağ tık menüsünde liste sıfırlama görünüyor.
- [ ] Sıfırlama uyarısında Vazgeç kayıtları koruyor; Listeyi Sıfırla sonrası yeni küçültme turu başlayabiliyor.
- [ ] İzin, kısayol çakışması ve girişte başlatma hatası uyarıları görünür açılıyor.
- [ ] Sağ tık menüsü kapanınca sol tık toggle çalışıyor; menü titremiyor.
- [ ] 1 saniyelik AX timeout'u yoğun fakat sağlıklı uygulamalarda gereksiz hataya yol açmıyor.

- 0.1.1 kullanıcı doğrulaması: hızlı 5–6 kısayol basışı sonrası takılma olmadı; sağ tık menüsü ve sonraki toggle çalıştı. Bu gözlem, işlem sırasında iç kuyruğun durumunu veya yanıt vermeyen uygulama senaryosunu doğrulamaz.

- 0.1.1 kullanıcı doğrulaması: küçültme sonrası bir uygulamadan çıkıldığında kalan pencereler geri geliyor ve yeni toggle turu çalışıyor. Tek pencerenin kapanması ve yanıt vermeyen uygulama senaryoları ayrıca bekliyor.

- Kullanıcı netleştirdi: Excel kapatıldıktan sonra geri getirme testi başarılı. Yanıt vermeyen uygulama ve liste sıfırlama testleri yapılmadı; ilgili kutular açık.
