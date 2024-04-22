// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:test/test.dart';

void main() {
  test('Uint8List.fromList 有深拷贝', () {
    List<int> elements = [1, 2, 3, 4, 5];
    Uint8List uint8List = Uint8List.fromList(elements);

    elements[0] = 10;
    expect(elements[0], 10);
    expect(uint8List[0], 1);
  });
}
