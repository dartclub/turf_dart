import 'package:rbush/rbush.dart';
import 'package:turf/line_segment.dart';
import 'package:turf/meta.dart';
import 'package:turf/src/booleans/boolean_helper.dart';
import 'package:turf/turf.dart';
import 'invariant.dart';

/// Takes any [LineString], [MultiLineString], [Polygon] or [MultiPolygon] and
/// returns the overlapping lines between both features.
/// [feature1] first feature
/// [feature2] second feature
/// [tolerance] tolerance distance to match overlapping line segments, default is 0
/// [unit] the unit in which the tolerance is expressed, default is kilometers
/// returns [FeatureCollection<LineString>] lines(s) that are overlapping between both features
///
/// Example
/// ```dart
/// final line1 = lineString([[115, -35], [125, -30], [135, -30], [145, -35]]);
/// final line2 = lineString([[115, -25], [125, -30], [135, -30], [145, -25]]);
/// final overlapping = lineOverlap(line1, line2);
/// ```
FeatureCollection<LineString> lineOverlap(
  Feature feature1,
  Feature feature2, {
  num tolerance = 0,
  Unit unit = Unit.kilometers,
}) {
  if (!_isGeometrySupported(getGeom(feature1)) ||
      !_isGeometrySupported(getGeom(feature1))) {
    throw GeometryCombinationNotSupported(
        feature1.geometry!, feature2.geometry!);
  }

  final result = <Feature<LineString>>[];
  final tree = _FeatureRBush.create(lineSegment(feature1), tolerance, unit);

  // Iterate over segments of feature1
  segmentEach(feature2, (Feature<LineString> segmentF2, _, __, ___, ____) {
    // detect segments of feature1, that falls within the same
    // bonds of the current feature2 segment
    featureEach(tree.searchArea(segmentF2), (Feature current, _) {
      final segmentF1 = current as Feature<LineString>;

      // Are the current segments equal?
      if (booleanEqual(segmentF2.geometry!, segmentF1.geometry!)) {
        // add the complete segment to the result
        _addSegmentToResult(result, segmentF2);
        // continue with the next feature2 segment
        return false;
      }

      // Is the segment of feature2 a subset of the feature1 segment?
      if (_isSegmentOnLine(segmentF2, segmentF1, tolerance, unit)) {
        // add the complete segment to the result
        _addSegmentToResult(result, segmentF2);
        // continue with the next feature2 segment
        return false;
      }

      // Is the segment of feature1 a subset of the feature2 segment?
      if (_isSegmentOnLine(segmentF1, segmentF2, tolerance, unit)) {
        // add only the overlapping part
        _addSegmentToResult(result, segmentF1);
        // and continue with the next feature1 segment
        return true;
      }

      // If the segments of feature1 and feature2 didn't share any point and
      // the lines are overlapping partially, then we need to create a new
      // line segment with the overlapping part and add it to the result.
      final overlappingPart =
          _getOverlappingPart(segmentF2, segmentF1, tolerance, unit) ??
              _getOverlappingPart(segmentF1, segmentF2, tolerance, unit);
      if (overlappingPart != null) {
        // add only the overlapping part
        _addSegmentToResult(result, overlappingPart);
        // and continue with the next feature1 segment
        return true;
      }
    });
  });

  return FeatureCollection(features: result);
}

// If both lines didn't share any point, but
// - the start point of the second line is on the first line and
// - the end point of the first line is on the second line and
// - startPoint and endPoint are different,
// we can assume, that both lines are overlapping partially.
// first:        .-----------.
// second:             .-----------.
// startPoint:         .
// endPoint:                 .
// This solves the issue #901 and #2580 of TurfJs.
Feature<LineString>? _getOverlappingPart(
  Feature<LineString> first,
  Feature<LineString> second,
  num tolerance,
  Unit unit,
) {
  final firstCoords = _getCoorsSorted(first);
  final secondCoords = _getCoorsSorted(second);
  final startPoint = Point(coordinates: secondCoords.first);
  final endPoint = Point(coordinates: firstCoords.last);

  assert(firstCoords.length == 2, 'only 2 vertex lines are supported');
  assert(secondCoords.length == 2, 'only 2 vertex lines are supported');

  if (startPoint != endPoint &&
      _isPointOnLine(startPoint, first, tolerance, unit) &&
      _isPointOnLine(endPoint, second, tolerance, unit)) {
    return Feature(
      geometry: LineString(coordinates: [
        startPoint.coordinates,
        endPoint.coordinates,
      ]),
    );
  }
  return null;
}

List<Position> _getCoorsSorted(Feature feature) {
  final positions = getCoords(feature) as List<Position>;
  positions.sort((a, b) => a.lng < b.lng
      ? -1
      : a.lng > b.lng
          ? 1
          : 0);
  return positions;
}

bool _isPointOnLine(
  Point point,
  Feature<LineString> line,
  num tolerance,
  Unit unit,
) {
  final lineString = line.geometry as LineString;

  if (tolerance == 0) {
    return booleanPointOnLine(point, lineString);
  }
  final nearestPoint = nearestPointOnLine(lineString, point, unit);
  return nearestPoint.properties!['dist'] <= tolerance;
}

bool _isSegmentOnLine(
  Feature<LineString> segment,
  Feature<LineString> line,
  num tolerance,
  Unit unit,
) {
  final segmentCoords = getCoords(segment) as List<Position>;
  for (var i = 0; i < segmentCoords.length; i++) {
    final point = Point(coordinates: segmentCoords[i]);
    if (!_isPointOnLine(point, line, tolerance, unit)) {
      return false;
    }
  }
  return true;
}

void _addSegmentToResult(
  List<Feature<LineString>> result,
  Feature<LineString> segment,
) {
  // Only add the geometry to the result and remove the feature meta data
  final lineSegment = Feature<LineString>(geometry: segment.geometry);

  // find the feature that can be concatenated with the current segment
  for (var i = result.length - 1; i >= 0; i--) {
    final combined = _concat(result[i], lineSegment);
    if (combined != null) {
      result[i] = combined;
      return;
    }
  }
  // if no feature was found, add the segment as a new feature
  result.add(lineSegment);
}

Feature<LineString>? _concat(
  Feature<LineString> line,
  Feature<LineString> segment,
) {
  final lineCoords = getCoords(line) as List<Position>;
  final segmentCoords = getCoords(segment) as List<Position>;
  assert(lineCoords.length >= 2, 'line must have at least two coordinates.');
  assert(segmentCoords.length == 2, 'segment must have two coordinates.');

  final lineStart = lineCoords.first;
  final lineEnd = lineCoords.last;
  final segmentStart = segmentCoords.first;
  final segmentEnd = segmentCoords.last;

  List<Position> linePositions =
      (line.geometry as LineString).clone().coordinates;

  if (segmentStart == lineStart) {
    linePositions.insert(0, segmentEnd);
  } else if (segmentEnd == lineStart) {
    linePositions.insert(0, segmentStart);
  } else if (segmentStart == lineEnd) {
    linePositions.add(segmentEnd);
  } else if (segmentEnd == lineEnd) {
    linePositions.add(segmentStart);
  } else {
    // Segment couldn't be concatenated, because the segment didn't
    // share any point with the line.
    return null;
  }

  return Feature(geometry: LineString(coordinates: linePositions));
}

// The RBush Package generally supports own types for the spatial index.
// Something like RBushBase<Feature<LineString>> should be possible, but
// I had problems to get it to work. This is a workaround until I have the
// time to figure out how to use the RBush Package with the Feature<LineString>
class _FeatureRBush {
  _FeatureRBush._(
    List<List<List<double>>> segments,
    this.tolerance,
    this.unit,
  ) {
    _tree = RBushBase<List<List<double>>>(
      maxEntries: 4,
      toBBox: (segment) => _boundingBoxOf(segment),
      getMinX: (segment) => _boundingBoxOf(segment).minX,
      getMinY: (segment) => _boundingBoxOf(segment).minY,
    );
    _tree.load(segments);
  }

  late RBushBase<List<List<double>>> _tree;
  final num tolerance;
  final Unit unit;

  static _FeatureRBush create(
    FeatureCollection<LineString> segments,
    num tolerance,
    Unit unit,
  ) {
    final converted = segments.features
        .map((e) => (e.geometry as LineString)
            .coordinates
            .map((e) => [e.lng.toDouble(), e.lat.toDouble()])
            .toList())
        .toList();

    return _FeatureRBush._(converted, tolerance, unit);
  }

  FeatureCollection<LineString> searchArea(Feature<LineString> segment) {
    final coordinates = segment.geometry!.coordinates
        .map((e) => [e.lng.toDouble(), e.lat.toDouble()])
        .toList();
    return _buildFeatureCollection(
      _tree.search(
        _boundingBoxOf(coordinates),
      ),
    );
  }

  FeatureCollection<LineString> _buildFeatureCollection(
    List<List<List<num>>> result,
  ) {
    return FeatureCollection<LineString>(
      features: result
          .map(
            (e) => Feature(
              geometry: LineString(
                coordinates: e.map((e) => Position.of(e)).toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  RBushBox _withTolerance(RBushBox box) {
    final min = destination(
      destination(
        Point(
          coordinates: Position.named(
            lat: box.minX,
            lng: box.minY,
          ),
        ),
        tolerance,
        180,
        unit,
      ),
      tolerance,
      270,
      unit,
    );

    final max = destination(
      destination(
          Point(
            coordinates: Position.named(
              lat: box.maxX,
              lng: box.maxY,
            ),
          ),
          tolerance,
          0,
          unit),
      tolerance,
      90,
      unit,
    );

    return RBushBox(
      minX: min.coordinates.lat.toDouble(),
      minY: min.coordinates.lng.toDouble(),
      maxX: max.coordinates.lat.toDouble(),
      maxY: max.coordinates.lng.toDouble(),
    );
  }

  RBushBox _boundingBoxOf(List<List<double>> coordinates) {
    final box = RBushBox();

    for (List<double> coordinate in coordinates) {
      box.extend(RBushBox(
        minX: coordinate[1], // lat1
        minY: coordinate[0], // lng1
        maxX: coordinate[1], // lat2
        maxY: coordinate[0], // lng2
      ));
    }

    return tolerance == 0 ? box : _withTolerance(box);
  }
}

bool _isGeometrySupported(GeometryObject geometry) {
  if (geometry is LineString ||
      geometry is MultiLineString ||
      geometry is Polygon ||
      geometry is MultiPolygon) {
    return true;
  }
  return false;
}
