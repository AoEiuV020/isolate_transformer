// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:js/js_util.dart' as js_util;

workerMain<S, T>(Stream<T> Function(Stream<S> e) mapper) {
  mapper(callbackToStream('onmessage', (html.MessageEvent e) {
    return js_util.getProperty(e, 'data');
  })).listen((message) async {
    jsSendMessage(message);
  });
}

Stream<Object> emptyTransformer<S, T>(Stream<Object> e) {
  return e;
}

Stream<T> callbackToStream<J, T>(
    String name, T Function(J jsValue) unwrapValue) {
  var controller = StreamController<T>.broadcast(sync: true);
  js_util.setProperty(js.context['self'], name, js.allowInterop((J event) {
    controller.add(unwrapValue(event));
  }));
  return controller.stream;
}

void jsSendMessage(dynamic m) {
  js.context.callMethod('postMessage', [m]);
}