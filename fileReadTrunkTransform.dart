import 'package:example/src/function/file.dart';
import 'package:isolate_transformer/worker_transformer.dart';

/// dart compile js fileReadTrunkTransform.dart -o fileReadTrunkTransform.js -O4
/// emptyTransformer替换成自己需要的transformer函数，
main() {
  workerMain(fileReadTrunkTransform);
}
