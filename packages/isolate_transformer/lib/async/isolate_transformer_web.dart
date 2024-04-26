// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';
import 'dart:js_util';

import 'package:isolate_transformer/isolate_stream_done.dart';
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
    data.listen(
      (event) {
        worker.postMessage(event);
      },
      onDone: () {
        worker.postMessage(const IsolateStreamDone().toJson());
      },
    );
    await for (var event in worker.onMessage) {
      final data = event.data;
      // 这里是异步线程内抛出的异常，
      if (data is Map) {
        // 魔法代码，不知道为什么是o，
        final o = data['o'];
        if (o is Map && o['type'] == 'IsolateException') {
          final exception =
              IsolateException.fromJson(Map<String, dynamic>.from(o));
          _kill(worker);
          yield* Stream.error(exception.error, exception.stackTrace);
          return;
        }
        if (o is Map && o['type'] == 'IsolateStreamDone') {
          _kill(worker);
          return;
        }
        if (o != null) {
          yield o as T;
          continue;
        }
      }
      if (data is T) {
        yield data;
      }
    }
  }

  void _kill(Worker worker) {
    worker.terminate();
    _cache.remove(worker);
  }

  @override
  Future<void> killAll() async {
    for (var worker in _cache) {
      worker.terminate();
    }
    _cache.clear();
  }
}
