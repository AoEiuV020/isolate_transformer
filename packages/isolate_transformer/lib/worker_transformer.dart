// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:isolate_transformer/isolate_exception.dart';
import 'package:isolate_transformer/isolate_stream_done.dart';
import 'package:js/js_util.dart';
import 'package:js/js.dart';

/// 用于worker,
/// web真异步需要单独的js文件入口，该js可以是dart编译生成的，
///
/// 也就是说必须一个包含main方法的dart代码，
/// 此处封装目的就是简化该dart入口代码，只要一行代码传入需要的Stream转化方法，
///
/// emptyTransformer要替换成自己实际需要的方法，
/// ```
/// main() {
///   workerMain(emptyTransformer);
/// }
/// ```
workerMain<S, T>(Stream<T> Function(Stream<S> e) mapper) {
  final Stream<T> stream;
  try {
    stream = mapper(callbackToStream('onmessage'));
  } catch (e, s) {
    // 针对mapper本身不是async方法，同步执行时抛异常的情况，
    if (e is Error || e is Exception) {
      // 异常传到主线程再抛出，
      jsSendMessage(IsolateException(e, s).toJson());
      return;
    }
    rethrow;
  }

  stream.listen(
    (message) async {
      jsSendMessage(message);
    },
    onError: (e, s) {
      if (e is Error || e is Exception) {
        jsSendMessage(IsolateException(e, s).toJson());
      }
    },
    onDone: () {
      jsSendMessage(IsolateStreamDone().toJson());
    },
  );
}

Stream<Object> emptyTransformer<S, T>(Stream<Object> e) {
  return e;
}

Stream<T> callbackToStream<T>(String name) {
  var controller = StreamController<T>.broadcast(sync: true);
  setProperty(context['self'], name, allowInterop((MessageEvent event) {
    final data = dartify(getProperty(event, 'data'));
    if (data is Map && data['type'] == 'IsolateStreamDone') {
      controller.close();
      return;
    }
    controller.add(data as T);
  }));
  return controller.stream;
}

void jsSendMessage(dynamic m) {
  context.callMethod('postMessage', [jsify(m)]);
}
