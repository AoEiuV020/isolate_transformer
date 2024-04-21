import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:isolate_transformer/isolate_transformer.dart';


class AsyncDecoder {
  Stream<String> decode(Stream<List<int>> data) {
    return IsolateTransformer().transform(
        data,
        (e) => e
            .transform(const Utf8Decoder(allowMalformed: true))
            .transform(const StringConverter()));
  }
}

class StringConverter extends Converter<String, String> {
  const StringConverter();

  @override
  String convert(String input) {
    // unreachable,
    return input;
  }

  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    return StringSink(sink);
  }
}

class StringSink implements Sink<String> {
  StringSink(this.sink);

  final Sink<String> sink;

  @override
  void add(String data) {
    const max = 1000;
    for (int i = 0; i < data.length; i += max) {
      sink.add(data.substring(i, math.min(i + max, data.length)));
    }
  }

  @override
  void close() {
    sink.close();
  }
}
