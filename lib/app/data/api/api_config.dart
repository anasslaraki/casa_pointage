/// Build-time settings. The key is never stored in the source:
/// `flutter run --dart-define=POINTAGE_API_KEY=<key>`.
abstract class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'POINTAGE_BASE_URL',
    defaultValue: 'https://func-pointageapp-prod-eus-02.azurewebsites.net/api',
  );

  static const apiKey = String.fromEnvironment('POINTAGE_API_KEY');
}
