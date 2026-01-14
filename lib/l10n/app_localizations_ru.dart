// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get loginAccount => 'Войдите в свой аккаунт';

  @override
  String get email => 'Эл. почта';

  @override
  String get emailPlaceholder => 'Введите эл. почту';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHintText => 'Введите пароль';

  @override
  String get login => 'Войти';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get enterEmail => 'Пожалуйста, введите эл. почту';

  @override
  String get enterPassword => 'Пожалуйста, введите пароль';

  @override
  String get passwordLeastCharacter => 'Пароль должен содержать не менее 6 символов';

  @override
  String get validEmail => 'Введите корректный эл. адрес';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get savedAccounts => 'Сохраненные аккаунты';

  @override
  String get registerSuccess => 'Регистрация прошла успешно!';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get registerAndChat => 'Зарегистрируйтесь и начните общаться';

  @override
  String get fullName => 'ФИО';

  @override
  String get enterName => 'Введите ваше имя';

  @override
  String get enterNameError => 'Введите имя';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get confirmPasswordError => 'Подтвердите пароль';

  @override
  String get passwordMismatchError => 'Пароли не совпадают';

  @override
  String get registerAction => 'Зарегистрироваться';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get loginAction => 'Войти';

  @override
  String get messagesTitle => 'Сообщения';

  @override
  String get searchHint => 'Поиск...';

  @override
  String get noChats => 'Вы еще ни с кем не общались';

  @override
  String get newMessage => 'Новое сообщение';

  @override
  String get searchUserHint => 'Поиск пользователя...';

  @override
  String get noUsersFound => 'Пользователь не найден';

  @override
  String get noUsersYet => 'Пока никого нет';

  @override
  String get newChat => 'Новый чат';

  @override
  String get now => 'Сейчас';

  @override
  String get deleteMessageTitle => 'Удалить сообщение?';

  @override
  String get deleteForMe => 'Удалить для меня';

  @override
  String get deleteForEveryone => 'Удалить для всех';

  @override
  String get cancel => 'Отмена';

  @override
  String get online => 'Онлайн';

  @override
  String get offline => 'Оффлайн';

  @override
  String get noMessages => 'Сообщений пока нет.';

  @override
  String get replyingTo => 'Ответ:';

  @override
  String get yourself => 'Вы';

  @override
  String get user => 'Пользователь';

  @override
  String get photo => '📷 Фото';

  @override
  String get typeMessage => 'Ваше сообщение...';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get notifications => 'Уведомления';

  @override
  String get receiveNotifications => 'Получать уведомления';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get darkMode => 'Темный режим';

  @override
  String get account => 'Аккаунт';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get deleteAccountDialogTitle => 'Удалить аккаунт';

  @override
  String get deleteAccountDialogContent => 'Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить.';

  @override
  String get no => 'Нет';

  @override
  String get yesDelete => 'Да, удалить';

  @override
  String get deleteAccountReauthError => 'Ошибка: Вам нужно снова войти, чтобы удалить аккаунт.';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get profilePhotoUpdating => 'Обновление фото профиля...';

  @override
  String get editProfileTitle => 'Редактирование профиля';

  @override
  String get save => 'Сохранить';

  @override
  String get profileUpdatedSuccess => 'Профиль успешно обновлен!';

  @override
  String get accountCenterTitle => 'Центр аккаунтов';

  @override
  String get newAccountLogin => 'Войти с новым аккаунтом';

  @override
  String get addAccount => 'Добавить аккаунт';

  @override
  String get removeAccountDialogTitle => 'Удалить аккаунт';

  @override
  String removeAccountDialogContent(String email) {
    return 'Вы уверены, что хотите удалить $email из списка?';
  }

  @override
  String get yes => 'Да';

  @override
  String get switchAccountDialogTitle => 'Сменить аккаунт';

  @override
  String switchAccountDialogContent(String email) {
    return 'Хотите переключиться на аккаунт $email?';
  }

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get clearAll => 'Очистить';

  @override
  String get clearAllDialogContent => 'Вы уверены, что хотите удалить все уведомления?';

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes мин. назад';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours ч. назад';
  }

  @override
  String get language => 'Язык';

  @override
  String get changeLanguage => 'Изменить язык';

  @override
  String get newPasswordHint => 'Новый пароль (оставьте пустым, если не меняете)';

  @override
  String get pleaseLogin => 'Пожалуйста, войдите';

  @override
  String get error => 'Ошибка';

  @override
  String get accounts => 'Аккаунты';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutDialogContent => 'Вы уверены, что хотите выйти?';

  @override
  String get filter => 'Фильтр';

  @override
  String get all => 'Все';

  @override
  String get read => 'Прочитанные';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get date => 'Дата';

  @override
  String get name => 'Имя';
}
