import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/polygon_clipping/flp.dart';

void main() {
  group('compare', () {
    test('exactly equal', () {
      final double a = 1;
      final double b = 1;
      expect(cmp(a, b), equals(0));
    });

    test('flp equal', () {
      final double a = 1;
      final double b = 1 + epsilon;
      expect(cmp(a, b), equals(0));
    });

    test('barely less than', () {
      final double a = 1;
      final double b = 1 + epsilon * 2;
      expect(cmp(a, b), equals(-1));
    });

    test('less than', () {
      final double a = 1;
      final double b = 2;
      expect(cmp(a, b), equals(-1));
    });

    test('barely more than', () {
      final double a = 1 + epsilon * 2;
      final double b = 1;
      expect(cmp(a, b), equals(1));
    });

    test('more than', () {
      final double a = 2;
      final double b = 1;
      expect(cmp(a, b), equals(1));
    });

    test('both flp equal to zero', () {
      final double a = 0.0;
      final double b = epsilon - epsilon * epsilon;
      expect(cmp(a, b), equals(0));
    });

    test('really close to zero', () {
      final double a = epsilon;
      final double b = epsilon + epsilon * epsilon * 2;
      expect(cmp(a, b), equals(-1));
    });
  });
}
