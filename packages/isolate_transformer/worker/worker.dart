// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:js/js_util.dart' as js_util;

/// dart compile js worker.dart -o worker.js -O4

/// In most cases you don't need to modify this function
main() {
  transformer(callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  })).listen((message) async {
    jsSendMessage(message);
  });
}

Stream<Object> transformer(Stream<Object> e) {
  return e;
}

/// Internal function
Stream<T> callbackToStream<J, T>(
    String name, T Function(J jsValue) unwrapValue) {
  var controller = StreamController<T>.broadcast(sync: true);
  js_util.setProperty(js.context['self'], name, js.allowInterop((J event) {
    controller.add(unwrapValue(event));
  }));
  return controller.stream;
}

/// Internal function
void jsSendMessage(dynamic m) {
  js.context.callMethod('postMessage', [m]);
}
