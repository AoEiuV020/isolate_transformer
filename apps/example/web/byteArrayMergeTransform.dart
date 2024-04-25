import 'package:example/src/function/byte_array.dart';
import 'package:isolate_transformer/worker_transformer.dart';

/// dart compile js byteArrayMergeTransform.dart -o byteArrayMergeTransform.js -O4
/// emptyTransformer替换成自己需要的transformer函数，
main() {
  workerMain(byteArrayMergeTransform);
}
