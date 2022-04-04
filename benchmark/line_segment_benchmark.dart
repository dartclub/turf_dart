import 'package:benchmark/benchmark.dart';
import 'package:turf/line_segment.dart';
import 'package:turf/helpers.dart';

void main() {
  LineString lineString = LineString(
    coordinates: [Position(1, 1), Position(2, 2), Position(3, 3)],
  );

  Feature<MultiLineString> multiLine = Feature<MultiLineString>(
    geometry: MultiLineString(
      coordinates: [
        [
          Position.of([5, 5]),
          Position.of([6, 6]),
          Position.of([9, 9])
        ],
        [
          Position.of([7, 7]),
          Position.of([8, 8]),
        ],
      ],
    ),
  );

  Feature<Polygon> poly = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position.of([0, 0]),
        Position.of([1, 1]),
        Position.of([0, 1]),
        Position.of([0, 0]),
      ],
    ]),
  );

  Feature<GeometryCollection> geomCollection1 = Feature<GeometryCollection>(
    geometry: GeometryCollection(
      geometries: [
        lineString,
      ],
    ),
  );

  Feature<Polygon> poly1 = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position.of([0, 0]),
        Position.of([2, 2]),
        Position.of([0, 1]),
        Position.of([0, 0]),
      ],
      [
        Position.of([0, 0]),
        Position.of([1, 1]),
        Position.of([0, 1]),
        Position.of([0, 0]),
      ],
    ]),
  );

  List<Feature<GeometryObject>> list = [
    multiLine,
    poly,
    poly1,
    geomCollection1
  ];
  List<Feature<GeometryObject>> list2 = [];
  for (int i = 0; i < list.length; i++) {
    for (int j = 0; j < 1000; j++) {
      list2.add(list[i]);
    }
  }
  FeatureCollection collection = FeatureCollection(
    features: list2,
  );
  group('lineSegment', () {
    benchmark('lineSegment', () {
      lineSegment(collection);
    });
    benchmark('segmentReduce', () {
      segmentReduce<int>(collection, (previousValue,
          currentSegment,
          initialValue,
          featureIndex,
          multiFeatureIndex,
          geometryIndex,
          segmentIndex) {
        if (previousValue != null) {
          previousValue++;
        }
        return previousValue;
      }, 0, combineNestedGeometries: false);
    });
  });
}
