import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/line_segment.dart';

/// Takes a [line] and measures its length in the specified [unit].
num? length(LineString line, [Unit unit = Unit.kilometers]) {
  return segmentReduce<num>(line, (
    previousValue,
    currentSegment,
    initialValue,
    featureIndex,
    multiFeatureIndex,
    geometryIndex,
    segmentIndex,
  ) {
    final coords = currentSegment.geometry!.coordinates;
    return previousValue! +
        distance(
          Point(coordinates: coords[0]),
          Point(coordinates: coords[1]),
          unit,
        );
  }, 0.0);
}
