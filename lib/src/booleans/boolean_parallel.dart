import 'package:turf/src/rhumb_bearing.dart';

import '../../helpers.dart';
import '../../line_segment.dart';
import '../clean_coords.dart';

/// Returns [true] if each segment of [line1] is parallel to the correspondent
/// segment of [line2]
/// example:
/// ```dart
/// var line1 = LineString(
///   coordinates: [
///     Position.of([0, 0]),
///     Position.of([0, 1])
///   ],
/// );
/// var line2 = LineString(
///   coordinates: [
///     Position.of([1, 0]),
///     Position.of([1, 1])
///   ],
/// );
/// booleanParallel(line1, line2);
/// //=true
/// ```
bool booleanParallel(LineString line1, LineString line2) {
  FeatureCollection<LineString> segments1 = lineSegment(cleanCoords(line1));
  FeatureCollection<LineString> segments2 = lineSegment(cleanCoords(line2));
  for (int i = 0; i < segments1.features.length; i++) {
    var segment1 = segments1.features[i].geometry!.coordinates;
    var seg2i = segments2.features.asMap().containsKey(i);
    if (!seg2i) break;
    var segment2 = segments2.features[i].geometry!.coordinates;
    if (!_isParallel(segment1, segment2)) return false;
  }
  return true;
}

/// Compares slopes and returns result
bool _isParallel(List<Position> segment1, List<Position> segment2) {
  var slope1 = bearingToAzimuth(rhumbBearing(
      Point(coordinates: segment1[0]), Point(coordinates: segment1[1])));
  var slope2 = bearingToAzimuth(rhumbBearing(
      Point(coordinates: segment2[0]), Point(coordinates: segment2[1])));
  return slope1 == slope2;
}
