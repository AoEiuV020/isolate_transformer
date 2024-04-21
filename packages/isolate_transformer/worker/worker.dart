import 'package:isolate_transformer/worker_transformer.dart';

/// dart compile js worker.dart -o worker.js -O4
/// emptyTransformer替换成自己需要的transformer函数，
main() {
  workerMain(emptyTransformer);
}
