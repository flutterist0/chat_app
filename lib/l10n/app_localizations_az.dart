// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get welcome => 'Xoş gəlmisiniz';

  @override
  String get loginAccount => 'Hesabınıza daxil olun';

  @override
  String get email => 'E-poçt';

  @override
  String get emailPlaceholder => 'E-poçtunuzu daxil edin';

  @override
  String get password => 'Şifrə';

  @override
  String get passwordHintText => 'Şifrənizi daxil edin';

  @override
  String get login => 'Daxil ol';

  @override
  String get dontHaveAccount => 'Hesabınız yoxdur?';

  @override
  String get register => 'Qeydiyyatdan keçin';

  @override
  String get enterEmail => 'Zəhmət olmasa e-poçt daxil edin';

  @override
  String get enterPassword => 'Zəhmət olmasa şifrə daxil edin';

  @override
  String get passwordLeastCharacter => 'Şifrə ən azı 6 simvol olmalıdır';

  @override
  String get validEmail => 'Düzgün e-poçt daxil edin';

  @override
  String get continueWithGoogle => 'Google ilə davam et';

  @override
  String get savedAccounts => 'Yadda saxlanılan hesablar';

  @override
  String get registerSuccess => 'Qeydiyyat uğurla tamamlandı!';

  @override
  String get createAccount => 'Hesab yaradın';

  @override
  String get registerAndChat => 'Qeydiyyatdan keçin və söhbətə başlayın';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get enterName => 'Adınızı daxil edin';

  @override
  String get enterNameError => 'Ad daxil edin';

  @override
  String get confirmPassword => 'Şifrəni təsdiq edin';

  @override
  String get confirmPasswordError => 'Şifrəni təsdiq edin';

  @override
  String get passwordMismatchError => 'Şifrələr uyğun gəlmir';

  @override
  String get registerAction => 'Qeydiyyatdan keç';

  @override
  String get alreadyHaveAccount => 'Artıq hesabınız var? ';

  @override
  String get loginAction => 'Daxil olun';

  @override
  String get messagesTitle => 'Mesajlar';

  @override
  String get searchHint => 'Axtar...';

  @override
  String get noChats => 'Hələ heç kimlə danışmamısınız';

  @override
  String get newMessage => 'Yeni Mesaj';

  @override
  String get searchUserHint => 'İstifadəçi axtar...';

  @override
  String get noUsersFound => 'İstifadəçi tapılmadı';

  @override
  String get noUsersYet => 'Hələ heç kim yoxdur';

  @override
  String get newChat => 'Yeni söhbət';

  @override
  String get now => 'İndi';

  @override
  String get deleteMessageTitle => 'Mesajı silmək istəyirsiniz?';

  @override
  String get deleteForMe => 'Mənim üçün sil';

  @override
  String get deleteForEveryone => 'Hər kəs üçün sil';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get online => 'Onlayn';

  @override
  String get offline => 'Oflayn';

  @override
  String get noMessages => 'Hələ mesaj yoxdur.';

  @override
  String get replyingTo => 'Cavab verilir:';

  @override
  String get yourself => 'Özünə';

  @override
  String get user => 'İstifadəçi';

  @override
  String get photo => '📷 Şəkil';

  @override
  String get typeMessage => 'Mesaj yazın...';

  @override
  String get settingsTitle => 'Tənzimləmələr';

  @override
  String get notifications => 'Bildirişlər';

  @override
  String get receiveNotifications => 'Bildirişləri al';

  @override
  String get appearance => 'Görünüş';

  @override
  String get darkMode => 'Qaranlıq rejim';

  @override
  String get account => 'Hesab';

  @override
  String get editProfile => 'Profilə düzəliş et';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get aboutApp => 'Tətbiq Haqqında';

  @override
  String get version => 'Versiya';

  @override
  String get deleteAccountDialogTitle => 'Hesabı sil';

  @override
  String get deleteAccountDialogContent => 'Hesabınızı silmək istədiyinizə əminsiniz? Bu əməliyyat geri qaytarıla bilməz.';

  @override
  String get no => 'Xeyr';

  @override
  String get yesDelete => 'Bəli, sil';

  @override
  String get deleteAccountReauthError => 'Xəta: Hesabı silmək üçün yenidən giriş etməlisiniz.';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Qalereya';

  @override
  String get removePhoto => 'Şəkli sil';

  @override
  String get profilePhotoUpdating => 'Profil şəkli yenilənir...';

  @override
  String get editProfileTitle => 'Profilə Düzəliş';

  @override
  String get save => 'Yadda Saxla';

  @override
  String get profileUpdatedSuccess => 'Profil uğurla yeniləndi!';

  @override
  String get accountCenterTitle => 'Hesab Mərkəzi';

  @override
  String get newAccountLogin => 'Yeni hesab ilə giriş';

  @override
  String get addAccount => 'Hesab əlavə et';

  @override
  String get removeAccountDialogTitle => 'Hesabı sil';

  @override
  String removeAccountDialogContent(String email) {
    return '$email hesabını siyahıdan silmək istədiyinizə əminsiniz?';
  }

  @override
  String get yes => 'Bəli';

  @override
  String get switchAccountDialogTitle => 'Hesabı dəyiş';

  @override
  String switchAccountDialogContent(String email) {
    return '$email hesabına keçmək istəyirsiniz?';
  }

  @override
  String get notificationsTitle => 'Bildirişlər';

  @override
  String get clearAll => 'Təmizlə';

  @override
  String get clearAllDialogContent => 'Bütün bildirişləri silmək istədiyinizə əminsiniz?';

  @override
  String get noNotifications => 'Bildiriş yoxdur';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes dəqiqə əvvəl';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours saat əvvəl';
  }

  @override
  String get language => 'Dil';

  @override
  String get changeLanguage => 'Dili dəyiş';

  @override
  String get newPasswordHint => 'Yeni Şifrə (Dəyişmək istəmirsinizsə boş buraxın)';

  @override
  String get pleaseLogin => 'Zəhmət olmasa daxil olun';

  @override
  String get error => 'Xəta';

  @override
  String get accounts => 'Hesablar';

  @override
  String get logout => 'Çıxış';

  @override
  String get logoutDialogContent => 'Hesabdan çıxmaq istədiyinizə əminsiniz?';

  @override
  String get filter => 'Filtr';

  @override
  String get all => 'Hamısı';

  @override
  String get read => 'Oxunmuş';

  @override
  String get unread => 'Oxunmamış';

  @override
  String get sortBy => 'Sırala';

  @override
  String get date => 'Tarix';

  @override
  String get name => 'Ad';
}
