// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:isolate_transformer/isolate_transformer.dart';

import '../isolate_exception.dart';

class IsolateTransformerImpl implements IsolateTransformer {
  final Set<Worker> _cache = {};
  @override
  Stream<T> transform<S, T>(
      Stream<S> data, Stream<T> Function(Stream<S> e) mapper,
      {String workerName = ''}) async* {
    if (workerName.isEmpty || !Worker.supported) {
      yield* mapper(data);
      return;
    }
    final worker = Worker('$workerName.js');
    _cache.add(worker);
    data.listen((event) {
      worker.postMessage(event);
    });
    await for (var event in worker.onMessage) {
      final data = event.data;
      // 这里是异步线程内抛出的异常，
      if (data is Map) {
        // 魔法代码，不知道为什么是o，
        final o = data['o'];
        if (o is Map && o['type'] == 'IsolateException') {
          final exception =
              IsolateException.fromJson(Map<String, dynamic>.from(o));
          worker.terminate();
          _cache.remove(worker);
          yield* Stream.error(exception.error, exception.stackTrace);
          return;
        }
      }
      if (data is T) {
        yield data;
      }
    }
  }

  @override
  Future<void> killAll() async {
    for (var worker in _cache) {
      worker.terminate();
    }
    _cache.clear();
  }
}
