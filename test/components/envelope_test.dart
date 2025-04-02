import 'package:turf/turf.dart';
import 'package:test/test.dart';

void main() {
  final point = Feature<Point>(
      geometry: Point(coordinates: Position.named(lat: 102.0, lng: 0.5)));

  final line = Feature<LineString>(
    geometry: LineString(coordinates: [
      Position.named(lat: 102.0, lng: 0.5),
      Position.named(lat: 103.0, lng: 1.5),
      Position.named(lat: 104.0, lng: 2.5),
    ])
  );

  test("envelope for point", () {
    // Point
    final pointEnvelope = envelope(point);
    expect(
      pointEnvelope,
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
  });

  test("envelope for linestring", () {
    // LineString
    final lineEnvelope = envelope(line);

    // Directly use the expected envelope in the expect call
    expect(
      lineEnvelope,
      equals(Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position.named(lat: 102.0, lng: 0.5),
            Position.named(lat: 104.0, lng: 0.5),
            Position.named(lat: 104.0, lng: 2.5),
            Position.named(lat: 102.0, lng: 2.5),
            Position.named(lat: 102.0, lng: 0.5),
          ]
        ]),
      )),
      reason: "LineString",
    );
  });

  
}