library isolate_transformer;

import 'async/isolate_transformer.dart'
    if (dart.library.js_util) 'async/isolate_transformer_web.dart';

/// 异步转换Stream，为了能在异步线程执行Stream.transform，
///
/// 因为一些费时处理不好封装成一进一出的异步函数，
/// 可能是 N进M出 ，或者是希望每个输出都能及时在主线程接收处理，
/// 比如，
/// ```
///   File(filePath)
///       .openRead()
///       .transform(utf8.decoder)
///       .transform(const LineSplitter())
///       .forEach((line) {
///     print(line);
///   });
/// ```
/// 上述代码对比File.readAsLines不会一直等待直到全部读取解析完成，
/// 但是这段代码包含transform无法简单改成异步线程实现，哪怕这在原生开发是很普遍的做法，
///
/// 此时就需要IsolateTransformer将transform封装到异步线程处理，
abstract class IsolateTransformer {
  factory IsolateTransformer() => IsolateTransformerImpl();

  /// 异步执行Stream转换，
  /// [mapper] 在异步执行的方法，最好是顶层函数，否则可能因传入了无法序列化的对象导致失败，好在这种情况不论该对象是否有被使用都会崩溃，
  /// [workerName] 要支持web端真异步必须指定一个worker独立js文件在其中调用了传入的mapper, 参考/worker/worker.dart，js文件名'worker.js'对应参数workerName就是'worker',
  Stream<T> transform<S, T>(
      Stream<S> data, Stream<T> Function(Stream<S> e) mapper,
      {String workerName = ''});

  /// kill会停止执行中的所有异步工作，
  /// 但IsolateTransformer对象本身不会失效，
  /// kill之后还是可以使用transform开启新的异步工作，
  Future<void> killAll();
}
