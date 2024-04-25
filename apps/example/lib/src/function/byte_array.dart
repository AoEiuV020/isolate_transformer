import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

@pragma('vm:entry-point')
Stream<Uint8List> byteArrayMergeTransform(Stream<Uint8List> e) =>
    e.transform(const ByteArrayMergeConverter());

class ByteArrayMergeConverter extends Converter<Uint8List, Uint8List> {
  const ByteArrayMergeConverter();

  @override
  Uint8List convert(Uint8List input) {
    // unreachable,
    return input;
  }

  @override
  Sink<Uint8List> startChunkedConversion(Sink<Uint8List> sink) {
    log('startChunkedConversion');
    return ByteArrayMergeSink(sink);
  }
}

class ByteArrayMergeSink implements Sink<Uint8List> {
  ByteArrayMergeSink(this.sink);

  final Sink<Uint8List> sink;
  Uint8List buffer = Uint8List(0);
  var count = 1;
  var exists = 0;
  var length = 0;

  @override
  void add(Uint8List data) {
    log('input add: $exists/$count ${data.length}/$length');
    if (data.isEmpty) {
      throw StateError('data empty');
    }
    length += data.length;
    buffer = mergeUintLists([buffer, data]);
    ++exists;
    if (exists == count) {
      log('output add: $exists/$count ${buffer.length}/$length');
      sink.add(buffer);
      buffer = Uint8List(0);
      count *= 2;
      exists = 0;
    }
  }

  Uint8List mergeUintLists(List<Uint8List> lists) {
    int totalLength = lists.fold<int>(0, (acc, list) => acc + list.length);
    Uint8List mergedList = Uint8List(totalLength);
    int offset = 0;
    for (Uint8List list in lists) {
      mergedList.setRange(offset, offset + list.length, list);
      offset += list.length;
    }
    return mergedList;
  }

  @override
  void close() {
    sink.close();
  }
}
