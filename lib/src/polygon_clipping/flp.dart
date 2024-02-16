// Dart doesn't have integer math; everything is floating point.
// Precision is maintained using double-precision floating-point numbers.

// IE Polyfill (not applicable in Dart)
// If epsilon is undefined, set it to 2^-52 (similar to JavaScript).
// In Dart, this step is unnecessary.

// Calculate the square of epsilon for later use.

import 'package:turf/src/polygon_clipping/utils.dart';

const double epsilonsqrd = epsilon * epsilon;
// FLP (Floating-Point) comparator function
int cmp(double a, double b) {
  // Check if both numbers are close to zero.
  if (-epsilon < a && a < epsilon) {
    if (-epsilon < b && b < epsilon) {
      return 0; // Both numbers are effectively zero.
    }
  }

  // Check if the numbers are approximately equal (within epsilon).
  final double ab = a - b;
  if (ab * ab < epsilonsqrd * a * b) {
    return 0; // Numbers are approximately equal.
  }

  // Normal comparison: return -1 if a < b, 1 if a > b.
  return a < b ? -1 : 1;
}
