@pragma('vm:entry-point')
Stream<int> findPrimeNumbersTransform(Stream<int> numStream) =>
    numStream.asyncExpand((event) {
      return findPrimeNumbers(event * 10, 100);
    });

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
