import 'package:example/src/function/prime.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

void main() {
  IsolateTransformer()
      .transform(Stream.fromIterable([8, 88, -1]), findPrimeNumbersTransform)
      .listen(
    (int prime) {
      print(prime);
    },
    onError: (error, stackTrace) {
      print('Caught exception: $error');
    },
  );
}
