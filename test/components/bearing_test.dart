import 'package:test/test.dart';
import 'package:turf/bearing.dart';
import 'package:turf/helpers.dart';

main() {
  test('bearing', () {
    var start = Position.of([-75, 45]);
    var end = Position.of([20, 60]);

    var initialBearing = bearingRaw(start, end);
    expect(initialBearing.toStringAsFixed(2), '37.75');

    var finalBearing = bearingRaw(start, end, calcFinal: true);
    expect(finalBearing.toStringAsFixed(2), '120.01');
  });
}
