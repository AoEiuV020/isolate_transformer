import 'dart:async';
import 'dart:collection';
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

class StreamSplit<T> {
  final Stream<T> stream;
  final Queue<Completer<void Function(T)>> _inputWaiters = Queue();
  final Queue<Completer<T>> _outputWaiters = Queue();
  var started = false;

  StreamSplit(this.stream);

  Stream<T> take(int count) async* {
    if (!started) {
      asyncOperation(stream).listen((event) {});
      started = true;
    }
    for (var i = 0; i < count; i++) {
      try {
        yield await takeOne();
      } on _NoMoreError {
        return;
      }
    }
  }

  Stream<void> asyncOperation(Stream<T> stream) async* {
    await for (var data in stream) {
      if (_outputWaiters.isNotEmpty) {
        _outputWaiters.removeFirst().complete(data);
        continue;
      }
      final completer = Completer<void Function(T)>();
      _inputWaiters.add(completer);
      final callback = await completer.future;
      callback.call(data);
      yield null;
    }
    for (var output in _outputWaiters) {
      output.completeError(const _NoMoreError());
    }
  }

  Future<T> takeOne() {
    if (!started) {
      asyncOperation(stream).listen((event) {});
      started = true;
    }
    final completer = Completer<T>();
    if (_inputWaiters.isNotEmpty) {
      _inputWaiters.removeFirst().complete((data) {
        _outputWaiters.remove(completer);
        completer.complete(data);
      });
    }
    _outputWaiters.add(completer);
    return completer.future;
  }
}

class _NoMoreError {
  const _NoMoreError();
}
