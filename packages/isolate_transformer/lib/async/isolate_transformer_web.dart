// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:isolate_transformer/isolate_transformer.dart';

class IsolateTransformerImpl implements IsolateTransformer {
  final Set<Worker> _cache = {};
  @override
  Stream<T> transform<S, T>(
      Stream<S> data, Stream<T> Function(Stream<S> e) mapper,
      {String workerName = ''}) async* {
    if (workerName.isEmpty) {
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
