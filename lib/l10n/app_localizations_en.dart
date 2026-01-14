// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get loginAccount => 'Login to your account';

  @override
  String get email => 'Email';

  @override
  String get emailPlaceholder => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get passwordHintText => 'Enter your password';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get enterEmail => 'Please enter email';

  @override
  String get enterPassword => 'Please enter password';

  @override
  String get passwordLeastCharacter => 'Password must be at least 6 characters';

  @override
  String get validEmail => 'Please enter a valid email';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get savedAccounts => 'Saved accounts';

  @override
  String get registerSuccess => 'Registration successful!';

  @override
  String get createAccount => 'Create account';

  @override
  String get registerAndChat => 'Register and start chatting';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get enterNameError => 'Please enter name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordError => 'Please confirm password';

  @override
  String get passwordMismatchError => 'Passwords do not match';

  @override
  String get registerAction => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginAction => 'Login';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get searchHint => 'Search...';

  @override
  String get noChats => 'You haven\'t talked to anyone yet';

  @override
  String get newMessage => 'New Message';

  @override
  String get searchUserHint => 'Search user...';

  @override
  String get noUsersFound => 'User not found';

  @override
  String get noUsersYet => 'No users yet';

  @override
  String get newChat => 'New chat';

  @override
  String get now => 'Now';

  @override
  String get deleteMessageTitle => 'Delete message?';

  @override
  String get deleteForMe => 'Delete for me';

  @override
  String get deleteForEveryone => 'Delete for everyone';

  @override
  String get cancel => 'Cancel';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get noMessages => 'No messages yet.';

  @override
  String get replyingTo => 'Replying to:';

  @override
  String get yourself => 'Yourself';

  @override
  String get user => 'User';

  @override
  String get photo => '📷 Photo';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get receiveNotifications => 'Receive notifications';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version';

  @override
  String get deleteAccountDialogTitle => 'Delete account';

  @override
  String get deleteAccountDialogContent => 'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get no => 'No';

  @override
  String get yesDelete => 'Yes, delete';

  @override
  String get deleteAccountReauthError => 'Error: You must re-login to delete the account.';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get profilePhotoUpdating => 'Updating profile photo...';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get accountCenterTitle => 'Account Center';

  @override
  String get newAccountLogin => 'Login with new account';

  @override
  String get addAccount => 'Add account';

  @override
  String get removeAccountDialogTitle => 'Remove account';

  @override
  String removeAccountDialogContent(String email) {
    return 'Are you sure you want to remove $email from the list?';
  }

  @override
  String get yes => 'Yes';

  @override
  String get switchAccountDialogTitle => 'Switch account';

  @override
  String switchAccountDialogContent(String email) {
    return 'Do you want to switch to $email?';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearAllDialogContent => 'Are you sure you want to delete all notifications?';

  @override
  String get noNotifications => 'No notifications';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get newPasswordHint => 'New Password (leave blank to keep current)';

  @override
  String get pleaseLogin => 'Please login';

  @override
  String get error => 'Error';

  @override
  String get accounts => 'Accounts';

  @override
  String get logout => 'Logout';

  @override
  String get logoutDialogContent => 'Are you sure you want to logout?';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get read => 'Read';

  @override
  String get unread => 'Unread';

  @override
  String get sortBy => 'Sort by';

  @override
  String get date => 'Date';

  @override
  String get name => 'Name';
}
