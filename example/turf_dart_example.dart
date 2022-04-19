import 'package:turf/helpers.dart';
import 'package:turf/src/line_segment.dart';

Feature<Polygon> poly = Feature<Polygon>(
  geometry: Polygon(coordinates: [
    [
      Position(0, 0),
      Position(2, 2),
      Position(0, 1),
      Position(0, 0),
    ],
    [
      Position(0, 0),
      Position(1, 1),
      Position(0, 1),
      Position(0, 0),
    ],
  ]),
);

main() {
  var total = segmentReduce<int>(
    poly,
    (previousValue, currentSegment, initialValue, featureIndex,
        multiFeatureIndex, geometryIndex, segmentIndex) {
      if (previousValue != null) {
        previousValue++;
      }
      return previousValue;
    },
    0,
    combineNestedGeometries: false,
  );
  print(total);
  // total ==  6
}
