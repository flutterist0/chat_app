# 📱 [Proyektin Adı] - Flutter Real-time Chat App

Bu layihə **Flutter** və **Firebase** texnologiyalarından istifadə edərək hazırlanmış, real vaxt rejimində işləyən (real-time) mesajlaşma tətbiqidir. Layihədə Clean Architecture prinsipləri, **BLoC** state management və Dependency Injection kimi müasir yanaşmalardan istifadə olunmuşdur.

## ✨ Xüsusiyyətlər

* **Autentifikasiya:** Email/Şifrə və **Google Sign-In** ilə giriş.
* **Anlıq Mesajlaşma:** Cloud Firestore vasitəsilə gecikməsiz söhbət (1-ə 1).
* **Bildirişlər (Push Notifications):** Firebase Cloud Messaging (FCM) və Local Notifications inteqrasiyası (ön və arxa planda).
* **Media Paylaşımı:** Qalereyadan və ya kameradan şəkil göndərmə (Firebase Storage).
* **Emoji Dəstəyi:** Söhbət zamanı emojilərdən istifadə.
* **Responsive Dizayn:** `flutter_screenutil` sayəsində bütün ekran ölçülərinə uyğunlaşan UI.
* **Təhlükəsiz Yaddaş:** Token və həssas məlumatların `flutter_secure_storage` ilə qorunması.

## 📸 Ekran Görüntüləri (Screenshots)

<p align="center">
  <img src="assets/screenshots/login.png" width="200" alt="Login Page">
  <img src="assets/screenshots/chat.png" width="200" alt="Chat Page">
  <img src="assets/screenshots/profile.png" width="200" alt="Profile Page">
</p>

## 🛠 Texniki Stack və Paketlər

Layihə **Flutter 3.x** üzərində qurulub və aşağıdakı əsas kitabxanalardan istifadə olunub:

### Core & Architecture
* **[flutter_bloc](https://pub.dev/packages/flutter_bloc):** State Management (Mürəkkəb biznes məntiqini idarə etmək üçün).
* **[get_it](https://pub.dev/packages/get_it):** Dependency Injection (Service Locator).
* **[auto_route](https://pub.dev/packages/auto_route):** Naviqasiya və marşrutlama (Routing).

### Backend & Firebase
* **[firebase_auth](https://pub.dev/packages/firebase_auth):** İstifadəçi identifikasiyası.
* **[cloud_firestore](https://pub.dev/packages/cloud_firestore):** Real-time NoSQL verilənlər bazası.
* **[firebase_messaging](https://pub.dev/packages/firebase_messaging):** Push bildirişlər.
* **[firebase_storage](https://pub.dev/packages/firebase_storage):** Fayl və şəkil saxlama.

### UI & UX
* **[flutter_screenutil](https://pub.dev/packages/flutter_screenutil):** Ekran adaptasiyası.
* **[emoji_picker_flutter](https://pub.dev/packages/emoji_picker_flutter):** Emoji klaviaturası.
* **[image_picker](https://pub.dev/packages/image_picker):** Şəkil seçimi.

### Local Storage
* **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage):** Təhlükəsiz məlumat saxlama (Keychain/Keystore).
* **[shared_preferences](https://pub.dev/packages/shared_preferences):** Sadə yerli yaddaş.

## 🚀 İşə Salma (Installation)

Layihəni lokal kompüterinizdə işlətmək üçün aşağıdakı addımları izləyin:

1.  **Repozitoriyanı klonlayın:**
    ```bash
    git clone [https://github.com/username/project-name.git](https://github.com/username/project-name.git)
    cd project-name
    ```

2.  **Asılılıqları yükləyin:**
    ```bash
    flutter pub get
    ```

3.  **Code Generation (Vacib):**
    Layihədə `auto_route` və digər generatorlar istifadə olunduğu üçün bu əmri mütləq işlədin:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Firebase Quraşdırılması:**
    * Firebase konsolunda yeni layihə yaradın.
    * `google-services.json` (Android üçün) faylını `android/app/` qovluğuna əlavə edin.
    * `GoogleService-Info.plist` (iOS üçün) faylını `ios/Runner/` qovluğuna əlavə edin.

5.  **Tətbiqi işə salın:**
    ```bash
    flutter run
    ```

## 📂 Qovluq Strukturu

Layihə xüsusiyyətlərə görə (Feature-based) və ya Laylı (Layered) struktura uyğun təşkil edilmişdir:

```text
lib/
├── core/           # Ümumi istifadə olunan komponentlər, sabitlərlər (constants)
├── data/           # Repositories, API servisləri və modellər
├── logic/          # BLoC/Cubit faylları (State Management)
├── presentation/   # UI: Ekranlar və Widget-lar
├── routes/         # AutoRoute konfiqurasiyası
└── main.dart       # Tətbiqin giriş nöqtəsi
