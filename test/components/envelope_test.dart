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

  final poly = Feature<Polygon>(
      geometry: Polygon(coordinates: [
    [
      Position.named(lat: 101.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 1.0),
      Position.named(lat: 100.0, lng: 1.0),
      Position.named(lat: 100.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 0.0),
    ],
  ]));

  final multiLine = Feature<MultiLineString>(
      geometry: MultiLineString(coordinates: [
    [
      Position.named(lat: 100.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 1.0),
    ],
    [
      Position.named(lat: 102.0, lng: 2.0),
      Position.named(lat: 103.0, lng: 3.0),
    ],
  ]));

  final multiPoly = Feature<MultiPolygon>(
      geometry: MultiPolygon(coordinates: [
    [
      [
        Position.named(lat: 102.0, lng: 2.0),
        Position.named(lat: 103.0, lng: 2.0),
        Position.named(lat: 103.0, lng: 3.0),
        Position.named(lat: 102.0, lng: 3.0),
        Position.named(lat: 102.0, lng: 2.0),
      ],
    ],
    [
      [
        Position.named(lat: 100.0, lng: 0.0),
        Position.named(lat: 101.0, lng: 0.0),
        Position.named(lat: 101.0, lng: 1.0),
        Position.named(lat: 100.0, lng: 1.0),
        Position.named(lat: 100.0, lng: 0.0),
      ],
      [
        Position.named(lat: 100.2, lng: 0.2),
        Position.named(lat: 100.8, lng: 0.2),
        Position.named(lat: 100.8, lng: 0.8),
        Position.named(lat: 100.2, lng: 0.8),
        Position.named(lat: 100.2, lng: 0.2),
      ],
    ],
  ]));

  final fc =
      FeatureCollection(features: [point, line, poly, multiLine, multiPoly]);

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

  test("envelope for polygon", () {
    // Point
    final polyEnvelope = envelope(poly);
    expect(
      polyEnvelope,
      equals(Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position.named(lat: 100.0, lng: 0.0),
            Position.named(lat: 101.0, lng: 0.0),
            Position.named(lat: 101.0, lng: 1.0),
            Position.named(lat: 100.0, lng: 1.0),
            Position.named(lat: 100.0, lng: 0.0),
          ]
        ])
      )),
      reason: "polygon",
    );
  });

  test("envelope for multilinestring", () {
    // MultiLineString
    final multiLineEnvelope = envelope(multiLine);

    // Directly use the expected envelope in the expect call
    expect(
      multiLineEnvelope,
      equals(Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position.named(lat: 100.0, lng: 0.0),
            Position.named(lat: 103.0, lng: 0.0),
            Position.named(lat: 103.0, lng: 3.0),
            Position.named(lat: 100.0, lng: 3.0),
            Position.named(lat: 100.0, lng: 0.0),
          ]
        ]),
      )),
      reason: "MultiLineString",
    );
  });

  test("envelope for multipolygon", () {
    // MultiPolygon
    final multiPolyEnvelope = envelope(multiPoly);

    // Directly use the expected envelope in the expect call
    expect(
      multiPolyEnvelope,
      equals(Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position.named(lat: 100.0, lng: 0.0),
            Position.named(lat: 103.0, lng: 0.0),
            Position.named(lat: 103.0, lng: 3.0),
            Position.named(lat: 100.0, lng: 3.0),
            Position.named(lat: 100.0, lng: 0.0),
          ]
        ]),
      )),
      reason: "MultiPolygon",
    );
  });

  test("envelope for featureCollection", () {
    final fcEnvelope = envelope(fc);

    // The envelope should be a polygon that represents the minimum bounding rectangle
    // containing all features in the collection
    expect(
      fcEnvelope,
      equals(Feature<Polygon>(
        geometry: Polygon(coordinates: [
            [
              Position.named(lat: 100.0, lng: 0.0),
              Position.named(lat: 104.0, lng: 0.0),
              Position.named(lat: 104.0, lng: 3.0),
              Position.named(lat: 100.0, lng: 3.0),
              Position.named(lat: 100.0, lng: 0.0),
            ]
        ]),
      )),
      reason: "FeatureCollection",
    );
  });
}