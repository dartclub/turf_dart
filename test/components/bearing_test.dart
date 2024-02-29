import 'package:test/test.dart';
import 'package:turf/bearing.dart';

void main() {
  test(
    'bearing',
    () {
      var start = Point(coordinates: Position.of([-75, 45]));
      var end = Point(coordinates: Position.of([20, 60]));

      var initialBearing = bearing(start, end);
      expect(initialBearing.toStringAsFixed(2), '37.75');

      var finalBearing = bearing(start, end, calcFinal: true);
      expect(finalBearing.toStringAsFixed(2), '120.01');
      expect(finalBearing, calculateFinalBearing(start, end));
    },
  );
}
