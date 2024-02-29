import 'package:test/test.dart';
import 'package:turf/helpers.dart';

void main() {
  group('orient2d', () {
    test('return 0.0 for collinear points', () {
      // Test collinear points
      expect(orient2d(0, 0, 1, 1, 2, 2), equals(0.0));
    });

    test('return a positive value for clockwise points', () {
      // Test clockwise points
      expect(orient2d(0, 0, 1, 1, 2, 0), greaterThan(0.0));
    });

    test('return a negative value for counterclockwise points', () {
      // Test counterclockwise points
      expect(orient2d(0, 0, 2, 0, 1, 1), lessThan(0.0));
    });

    // Add more test cases here if needed
  });
}
