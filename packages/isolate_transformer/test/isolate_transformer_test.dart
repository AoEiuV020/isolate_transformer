// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    expect(1 + 1, 2);
  });
  test('error stack pair check', () {
    void foo(dynamic param0) {
      expect(param0.runtimeType.toString(), '(StateError, _StackTrace)');
      expect(param0 is Record, isTrue);
      final (error, stackTrace) = param0;
      expect(error is Error || error is Exception, isTrue);
      expect(stackTrace is StackTrace, isTrue);
      print(error);
      print(stackTrace);
    }

    foo((StateError('error message'), StackTrace.current));
  });
  test('error without stack', () {
    void foo(dynamic param0) {
      // 小坑，传入的元组删除其他只剩一个参数的时候就不是元组了，
      expect(param0.runtimeType.toString(), 'StateError');
      final error = param0;
      expect(error is Error || error is Exception, isTrue);
      print(error);
    }

    foo((StateError('error message')));
  });
  test('error with stack is null', () {
    void foo(dynamic param0) {
      expect(param0.runtimeType.toString(), '(StateError, Null)');
      final (error, stackTrace) = param0;
      expect(error is Error || error is Exception, isTrue);
      expect(stackTrace == null, isTrue);
      print(error);
    }

    foo((StateError('error message'), null));
  });
}
