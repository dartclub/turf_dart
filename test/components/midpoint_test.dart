import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/midpoint.dart';

main() {
  test('midpoint', () {
    _lngRange(num lng) => lng >= -180 && lng <= 180;
    _latRange(num lat) => lat >= -90 && lat <= 90;
    var result = midpoint(
      Point(
        coordinates: Position.named(
          lat: -33.4312226,
          lng: -70.5920118,
        ),
      ),
      Point(
        coordinates: Position.named(
          lat: -33.5149429,
          lng: -70.8961298,
        ),
      ),
    );
    print(result.coordinates.join(', '));
    expect(_lngRange(result.coordinates.lng), true);
    expect(_latRange(result.coordinates.lat), true);
  });
}
