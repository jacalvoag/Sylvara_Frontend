// lib/core/api/token_storage_web.dart
import 'dart:html' as html;

void webWrite(String key, String value) {
  html.window.localStorage[key] = value;
}

String? webRead(String key) {
  return html.window.localStorage[key];
}

void webDelete(String key) {
  html.window.localStorage.remove(key);
}