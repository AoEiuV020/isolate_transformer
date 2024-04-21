/// 异步执行的函数，
///
/// 放在顶层以免传递不必要的对象，
///
/// 声明entry-point以防万一被优化删除掉，
@pragma('vm:entry-point')
Stream<int> findPrimeNumbersTransform(Stream<int> numStream) =>
    numStream.asyncExpand((event) {
      return findPrimeNumbers(event * 10, 100);
    });
@pragma('vm:entry-point')
Stream<List> findPrimeNumbersListTransform(Stream<Map> numStream) =>
    numStream.asyncExpand((event) {
      int prime = event['prime'] ?? -1;
      int count = event['count'] ?? 100;
      int merge = event['merge'] ?? 2;
      return mergeResult(findPrimeNumbers(prime * 10, count), merge);
    });

Stream<List<T>> mergeResult<T>(Stream<T> input, int count) async* {
  List<T> buffer = [];

  await for (T value in input) {
    buffer.add(value);
    if (buffer.length == count) {
      yield buffer;
      buffer = [];
    }
  }

  if (buffer.isNotEmpty) {
    yield buffer;
  }
}

Stream<int> findPrimeNumbers(int from, int count) async* {
  int num = from;
  int found = 0;

  if (from < 0) {
    throw Exception('from不能是负数');
  }

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
