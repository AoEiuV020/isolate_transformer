import 'dart:convert';
import 'dart:math' as math;

/// 异步执行的函数，
///
/// 放在顶层以免传递不必要的对象，
///
/// 声明entry-point以防万一被优化删除掉，
@pragma('vm:entry-point')
Stream<String> fileReadTrunkTransform(Stream<List<int>> e) => e
    .transform(const Utf8Decoder(allowMalformed: true))
    .transform(const StringConverter());

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
