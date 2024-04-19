// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:example/src/function/prime.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:js/js.dart' as pjs;
import 'package:js/js_util.dart' as js_util;

@pjs.JS('self')
external dynamic get globalScopeSelf;

/// dart compile js prime.dart -o ../../../web/prime.js -O4

main() {
  findPrimeNumbersTransform(
      callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  })).listen((message) {
    jsSendMessage(message);
  }, onError: (err, stack) {
    jsSendMessage(IsolateException(err, stack).toJson());
  });
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
