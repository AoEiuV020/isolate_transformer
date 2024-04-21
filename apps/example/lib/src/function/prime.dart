import 'package:isolate_manager/isolate_manager.dart';

@pragma('vm:entry-point')
void findPrimeNumbersIsolateFunction(dynamic params) {
  final channel = IsolateManagerController<int, int>(params);
  findPrimeNumbersTransform(channel.onIsolateMessage).listen((message) {
    // 这里sendResult会调用多次但主线程收到的数据只有第一个， 
    channel.sendResult(message);
  });
}

@pragma('vm:entry-point')
Stream<int> findPrimeNumbersTransform(Stream<int> numStream) =>
    numStream.asyncExpand((event) {
      return findPrimeNumbers(event * 10, 100);
    });

Stream<int> findPrimeNumbers(int from, int count) async* {
  int num = from;
  int found = 0;

  while (found < count) {
    if (isPrime(num)) {
      yield num;
      found++;
    }
    num++;
  }
}

bool isPrime(int n) {
  if (n <= 1) return false;
  if (n <= 3) return true;

  if (n % 2 == 0 || n % 3 == 0) return false;

  int i = 5;
  while (i * i <= n) {
    if (n % i == 0 || n % (i + 2) == 0) return false;
    i += 6;
  }
  return true;
}
