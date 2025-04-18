import 'package:benchmark/benchmark.dart';
import 'package:turf/turf.dart';

// Create some test features for benchmarkings
final point = Feature(
  geometry: Point(coordinates: Position.of([5.0, 10.0])),
  properties: {'name': 'Test Point'},
);

final polygon = Feature<Polygon>(
  geometry: Polygon(coordinates: [
    [
      Position.of([-10.0, 0.0]),
      Position.of([10.0, 0.0]),
      Position.of([0.0, 20.0]),
      Position.of([-10.0, 0.0])
    ]
  ]),
  properties: {'name': 'Triangle Polygon'},
);

final lineString = Feature<LineString>(
  geometry: LineString(coordinates: [
    Position.of([0.0, 0.0]),
    Position.of([10.0, 10.0]),
    Position.of([20.0, 20.0])
  ]),
  properties: {'name': 'Line String Example'},
);

final featureCollection = FeatureCollection<GeometryObject>(features: [
  Feature(geometry: Point(coordinates: Position.of([0.0, 0.0]))),
  Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position.of([-10.0, -10.0]),
        Position.of([10.0, -10.0]),
        Position.of([10.0, 10.0]),
        Position.of([-10.0, 10.0]),
        Position.of([-10.0, -10.0]),
      ]
    ]),
    properties: {'name': 'Square Polygon'},
  )
]);

void main() {
  group('pointOnFeature', () {
    benchmark('point feature', () {
      pointOnFeature(point);
    });
    
    benchmark('polygon feature', () {
      pointOnFeature(polygon);
    });
    
    benchmark('lineString feature', () {
      pointOnFeature(lineString);
    });
    
    benchmark('feature collection', () {
      pointOnFeature(featureCollection);
    });
  });
}
