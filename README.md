# mirror media app
A new Flutter app about [mirror news](https://www.mnews.tw/).

## Running cli

### debug mode
- flutter run --flavor dev lib/main_dev.dart
- flutter run --flavor prod lib/main_prod.dart

### release mode
- flutter run --flavor dev --release lib/main_dev.dart
- flutter run --flavor prod --release lib/main_prod.dart
 
### generate dev release archive
 - flutter build appbundle --flavor dev lib/main_dev.dart
 - flutter build ios --flavor dev lib/main_dev.dart

### generate release archive
 - flutter build appbundle --flavor prod lib/main_prod.dart
 - flutter build ios --flavor prod lib/main_prod.dart

