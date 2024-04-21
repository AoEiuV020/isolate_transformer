import 'dart:async';
import 'dart:isolate';

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
    var mainReceive = ReceivePort();
    final isolate = await Isolate.spawn((SendPort sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      final streamController = StreamController<S>();
      mapper(streamController.stream).listen((event) {
        sendPort.send(event);
      }, onDone: () {
        // 这里把sendPort当成结束的标记使用，
        sendPort.send(sendPort);
      }, onError: (Object e, s) {
        if (e is Error) {
          // 异常传到主线程再抛出，
          sendPort.send(e);
        }
      });
      receivePort.listen((event) {
        // 这里把sendPort当成结束的标记使用，
        if (event == receivePort.sendPort) {
          streamController.close();
          return;
        }
        streamController.add(event as S);
      }, onDone: () {
        streamController.close();
      });
    }, mainReceive.sendPort,
        // 这里注册监听异步线程内抛出的异常，
        onError: mainReceive.sendPort);

    _cache.add(isolate);
    await for (var message in mainReceive) {
      if (message == mainReceive.sendPort) {
        // 这里把sendPort当成结束的标记使用，
        isolate.kill(priority: Isolate.immediate);
        _cache.remove(isolate);
        return;
      }
      if (message is SendPort) {
        data.listen((event) {
          message.send(event);
        }, onDone: () {
          // 这里把sendPort当成结束的标记使用，
          message.send(message);
        });
        continue;
      }
      // 这里是异步线程内抛出的异常，
      if (message is Error) {
        isolate.kill(priority: Isolate.immediate);
        _cache.remove(isolate);
        throw message;
      }
      yield message as T;
    }
  }

  // 关闭所有的 Isolate
  @override
  void killAll() {
    for (Isolate isolate in _cache) {
      isolate.kill(priority: Isolate.immediate);
    }
    _cache.clear();
  }
}
