import '../bean/count.dart';

class Prime {
  final _count = CountWrapper(count: 100);
  Stream<int> transform(Stream<int> numStream) => numStream
      .asyncExpand((event) => findPrimeNumbers(event * 10, _count.count));
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

  int findMaxPrime(int n) {
    var max = 0;
    for (var i = 0; i < n; ++i) {
      if (isPrime(i)) {
        max = i;
      }
    }
    return max;
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
}
