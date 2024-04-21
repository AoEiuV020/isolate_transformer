import 'package:example/src/function/prime.dart';
import 'package:isolate_transformer/worker_transformer.dart';

/// dart compile js findPrimeNumbersTransform.dart -o findPrimeNumbersTransform.js -O4
/// emptyTransformer替换成自己需要的transformer函数，
main() {
  workerMain(findPrimeNumbersTransform);
}
