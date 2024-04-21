library isolate_transformer;

import 'async/isolate_transformer.dart'
    if (dart.library.js_util) 'async/isolate_transformer_web.dart';

abstract class IsolateTransformer {
  factory IsolateTransformer() => IsolateTransformerImpl();
  Stream<T> transform<S, T>(
      Stream<S> data, Stream<T> Function(Stream<S> e) mapper,
      {String workerName = ''});

  void close();
}
