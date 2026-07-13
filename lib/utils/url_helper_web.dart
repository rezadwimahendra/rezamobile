import 'dart:js' as js;

void openUrl(String url) {
  js.context.callMethod('open', [url, '_blank']);
}
