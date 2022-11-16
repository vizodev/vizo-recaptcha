abstract class AppConstants {
  const AppConstants._();

  static String getRecaptchaWebViewUrl(String recaptchaUrl, String apiKey) => Uri.parse('$recaptchaUrl?api_key=$apiKey').toString();
}
