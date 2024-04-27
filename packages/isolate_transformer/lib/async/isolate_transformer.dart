import 'dart:async';
import 'dart:isolate';

import 'package:isolate_transformer/isolate_exception.dart';
import 'package:isolate_transformer/isolate_stream_done.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

class IsolateTransformerImpl implements IsolateTransformer {
  final Set<Isolate> _cache = {};

  @override
  Stream<T> transform<S, T>(
      Stream<S> data, Stream<T> Function(Stream<S> e) mapper,
      {String workerName = ''}) async* {
    if (const bool.fromEnvironment('dart.library.js_util')) {
      yield* mapper(data);
      return;
    }
    final mainReceive = ReceivePort();
    final isolate = await Isolate.spawn(_entry(mapper), mainReceive.sendPort,
        // 这里注册监听异步线程内抛出的异常，
        onError: mainReceive.sendPort);

    _cache.add(isolate);
    await for (var message in mainReceive) {
      if (message is SendPort) {
        data.listen((event) {
          // 这里无阻塞，所以数据会渊源不断的读取，不管能不能处理完，
          message.send(event);
        }, onDone: () {
          // 这里不能直接把mainReceive给close掉，以防万一异步数据还没处理完，输入的数据就已经非阻塞读取完了，
          message.send(const IsolateStreamDone());
        });
        continue;
      }
      if (message is IsolateStreamDone) {
        mainReceive.close();
        _kill(isolate);
        return;
      }
      // 这里是异步线程内抛出的异常，
      if (message is IsolateException) {
        mainReceive.close();
        _kill(isolate);
        yield* Stream.error(message.error, message.stackTrace);
        return;
      }
      yield message as T;
    }
    // unreachable,
    _kill(isolate);
  }

  void _kill(Isolate isolate) {
    isolate.kill(priority: Isolate.immediate);
    _cache.remove(isolate);
  }

  // 关闭所有的 Isolate
  @override
  Future<void> killAll() async {
    for (Isolate isolate in _cache) {
      isolate.kill(priority: Isolate.immediate);
    }
    _cache.clear();
  }
}

/// 顶层函数稳妥一点，避免误带入多余的对象，
void Function(SendPort) _entry<S, T>(Stream<T> Function(Stream<S> e) mapper) =>
    (SendPort sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      final streamController = StreamController<S>(sync: true);
      final Stream<T> stream;
      try {
        stream = mapper(streamController.stream);
      } catch (e, s) {
        // 针对mapper本身不是async方法，同步执行时抛异常的情况，
        if (e is Error || e is Exception) {
          // 异常传到主线程再抛出，
          sendPort.send(IsolateException(e, s));
          return;
        }
        rethrow;
      }
      stream.listen((event) {
        sendPort.send(event);
      }, onDone: () {
        receivePort.close();
        sendPort.send(const IsolateStreamDone());
      }, onError: (e, s) {
        if (e is Error || e is Exception) {
          // 异常传到主线程再抛出，
          sendPort.send(IsolateException(e, s));
        }
      });
      receivePort.listen((event) {
        if (event is IsolateStreamDone) {
          streamController.close();
          return;
        }
        streamController.add(event as S);
      }, onDone: () {
        streamController.close();
      });
    };
