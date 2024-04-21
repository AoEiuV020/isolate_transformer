// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:js/js_util.dart' as js_util;

/// 用于worker,
/// web真异步需要单独的js文件入口，该js可以是dart编译生成的，
/// 也就是说必须一个包含main方法的dart代码，
/// 此处封装目的就是简化该dart入口代码，只要一行代码传入需要的Stream转化方法，
/// emptyTransformer要替换成自己实际需要的方法，
/// main() {
///   workerMain(emptyTransformer);
/// }
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
