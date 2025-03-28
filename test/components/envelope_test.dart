import 'package:turf/turf.dart';
import 'package:test/test.dart';

void main() {
  final pt = Feature<Point>(
      geometry: Point(coordinates: Position.named(lat: 102.0, lng: 0.5)));

  test("envelope", () {
    // Point
    final ptEnvelope = envelope(pt);
    expect(
      ptEnvelope,
      equals(Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position.named(lat: 102.0, lng: 0.5),
            Position.named(lat: 102.0, lng: 0.5),
            Position.named(lat: 102.0, lng: 0.5),
            Position.named(lat: 102.0, lng: 0.5),
            Position.named(lat: 102.0, lng: 0.5),
          ]
        ])
      )),
      reason: "point",
    );
    
    // Print ptEnvelope here inside the test
    print(ptEnvelope);
  });
}