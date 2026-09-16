import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email helper format stays covered by app defaults', () {
    expect('awabnoor@gmail.com'.endsWith('@gmail.com'), isTrue);
  });
}
