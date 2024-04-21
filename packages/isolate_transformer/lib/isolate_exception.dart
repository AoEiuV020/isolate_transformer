/// 封装异步线程抛出的崩溃，
///
/// 在异步捕获崩溃得到IsolateException再抛到主线程，
class IsolateException {
  final dynamic error;
  final StackTrace? stackTrace;

  IsolateException(this.error, this.stackTrace);
  factory IsolateException.fromString(String error, String? stackTraceString) {
    StackTrace? stackTrace;
    if (stackTraceString is String && stackTraceString.isNotEmpty) {
      stackTrace = StackTrace.fromString(stackTraceString);
    }
    return IsolateException(MessageException(error), stackTrace);
  }
  factory IsolateException.fromJson(Map<String, dynamic> json) {
    final error = json['error'].toString();
    final stackTrace = json['stackTrace'].toString();
    return IsolateException.fromString(error, stackTrace);
  }

  Map<String, String> toJson() => {
        'type': 'IsolateException',
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      };
}

/// 用于异常详细信息丢失了只拥有message字符串的情况，
///
/// 具体就是web端worker异步中的异常无法抛到主线程，所以只保留字符串，
///
/// 但往外抛抛时希望抛的是Exception而不是String以便一些判断处理，
class MessageException implements Exception {
  final String message;
  MessageException(this.message);
  @override
  String toString() {
    return message;
  }
}
