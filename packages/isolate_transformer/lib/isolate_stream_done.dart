/// 用于标记Stream结束，
///
/// 主要针对web端的Worker，
/// 一方面传入的流无法关闭，
/// 一方面异步worker内调用close外部也收不到结束，
class IsolateStreamDone {
  IsolateStreamDone();
  Map<String, String> toJson() => const {
        'type': 'IsolateStreamDone',
      };
}
