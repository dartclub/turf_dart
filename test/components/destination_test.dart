import 'package:test/test.dart';
import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

main() {
  test('destination', () {
    var start = Position.named(
      lat: -33.4312226,
      lng: -70.5920118,
    );
    var end = Position.named(
      lat: -33.5149429,
      lng: -70.8961298,
    );
    var dist = distanceRaw(start, end);
    var bearing = bearingRaw(start, end);
    var newEnd = destinationRaw(start, dist, bearing).toSigned();

    var newDist = distanceRaw(start, newEnd);

    expect(dist.toStringAsFixed(8), newDist.toStringAsFixed(8));
    expect(end.lng.toStringAsFixed(8), newEnd.lng.toStringAsFixed(8));
    expect(end.lat.toStringAsFixed(8), newEnd.lat.toStringAsFixed(8));
  });
}
