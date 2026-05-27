class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const pollingInterval = Duration(seconds: 6);
  static const systemPollingInterval = Duration(seconds: 8);
  static const requestTimeout = Duration(seconds: 5);
  static const retryCount = 2;
}
