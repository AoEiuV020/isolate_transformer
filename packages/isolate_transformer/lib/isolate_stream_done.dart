/// 用于标记Stream结束，
///
/// 数据传进异步线程这一步是无阻塞的，所以数据源的读取可能过快，
/// 为避免提前关闭了异步线程，需要把
class IsolateStreamDone {
  const IsolateStreamDone();
  Map<String, String> toJson() => const {
        'type': 'IsolateStreamDone',
      };
}
