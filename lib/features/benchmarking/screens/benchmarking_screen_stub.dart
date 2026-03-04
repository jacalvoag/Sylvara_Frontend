import 'package:url_launcher/url_launcher.dart';

void openUrlInBrowser(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}