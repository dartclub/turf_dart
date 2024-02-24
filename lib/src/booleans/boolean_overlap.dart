import 'package:turf/helpers.dart';
import 'package:turf/line_overlap.dart';
import 'package:turf/line_segment.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/line_intersect.dart';
import 'package:turf_equality/turf_equality.dart';
import 'boolean_helper.dart';

/// Takes two geometries [firstFeature] and [secondFeature] and checks if they
/// share an common area but are not completely contained by each other.
///
/// Supported Geometries are `Feature<MultiPoint>`, `Feature<LineString>`,
/// `Feature<MultiLineString>`, `Feature<Polygon>`, `Feature<MultiPolygon>`.
/// Features must be of the same type. LineString/MultiLineString and
/// Polygon/MultiPolygon combinations are supported. If the Geometries are not
/// supported an [GeometryNotSupported] or [GeometryCombinationNotSupported]
/// error is thrown.
///
/// Returns false if [firstFeature] and [secondFeature] are equal.
/// - MultiPoint: returns Returns true if the two MultiPoints share any point.
/// - LineString: returns true if the two Lines share any line segment.
/// - Polygon: returns true if the two Polygons intersect.
///
/// Example:
/// ```dart
///  final first = Polygon(coordinates: [
///    [
///      Position(0, 0),
///      Position(0, 5),
///      Position(5, 5),
///      Position(5, 0),
///      Position(0, 0)
///    ]
///  ]);
///  final second = Polygon(coordinates: [
///    [
///      Position(1, 1),
///      Position(1, 6),
///      Position(6, 6),
///      Position(6, 1),
///      Position(1, 1)
///    ]
///  ]);
///  final third = Polygon(coordinates: [
///    [
///      Position(10, 10),
///      Position(10, 15),
///      Position(15, 15),
///      Position(15, 10),
///      Position(10, 10)
///    ]
///  ]);
///
/// final isOverlapping = booleanOverlap(first, second);
/// final isNotOverlapping = booleanOverlap(second, third);
/// ```
bool booleanOverlap(
  Feature firstFeature,
  Feature secondFeature,
) {
  var first = getGeom(firstFeature);
  var second = getGeom(secondFeature);

  _checkIfGeometryCombinationIsSupported(first, second);

  final eq = Equality(
    reversedGeometries: true,
    shiftedPolygons: true,
  );
  if (eq.compare(first, second)) {
    return false;
  }

  switch (first.runtimeType) {
    case MultiPoint:
      switch (second.runtimeType) {
        case MultiPoint:
          return _isMultiPointOverlapping(
            first as MultiPoint,
            second as MultiPoint,
          );
        default:
          throw GeometryCombinationNotSupported(first, second);
      }
    case MultiLineString:
    case LineString:
      switch (second.runtimeType) {
        case LineString:
        case MultiLineString:
          return _isLineOverlapping(first, second);
        default:
          throw GeometryCombinationNotSupported(first, second);
      }
    case MultiPolygon:
    case Polygon:
      switch (second.runtimeType) {
        case Polygon:
        case MultiPolygon:
          return _isPolygonOverlapping(first, second);
        default:
          throw GeometryCombinationNotSupported(first, second);
      }
    default:
      throw GeometryCombinationNotSupported(first, second);
  }
}

bool _isGeometrySupported(GeometryObject geometry) =>
    geometry is MultiPoint ||
    geometry is LineString ||
    geometry is MultiLineString ||
    geometry is Polygon ||
    geometry is MultiPolygon;

void _checkIfGeometryCombinationIsSupported(
  GeometryObject first,
  GeometryObject second,
) {
  if (!_isGeometrySupported(first) || !_isGeometrySupported(second)) {
    throw GeometryCombinationNotSupported(first, second);
  }
}

void _checkIfGeometryIsSupported(GeometryObject geometry) {
  if (!_isGeometrySupported(geometry)) {
    throw GeometryNotSupported(geometry);
  }
}

List<Feature<LineString>> _segmentsOfGeometry(GeometryObject geometry) {
  _checkIfGeometryIsSupported(geometry);
  List<Feature<LineString>> segments = [];
  segmentEach(
    geometry,
    (Feature<LineString> segment, _, __, ___, ____) {
      segments.add(segment);
    },
  );
  return segments;
}

bool _isLineOverlapping(GeometryObject firstLine, GeometryObject secondLine) {
  for (final firstSegment in _segmentsOfGeometry(firstLine)) {
    for (final secondSegment in _segmentsOfGeometry(secondLine)) {
      if (lineOverlap(firstSegment, secondSegment).features.isNotEmpty) {
        return true;
      }
    }
  }
  return false;
}

bool _isPolygonOverlapping(
  GeometryObject firstPolygon,
  GeometryObject secondPolygon,
) {
  for (final firstSegment in _segmentsOfGeometry(firstPolygon)) {
    for (final secondSegment in _segmentsOfGeometry(secondPolygon)) {
      if (lineIntersect(firstSegment, secondSegment).features.isNotEmpty) {
        return true;
      }
    }
  }
  return false;
}

bool _isMultiPointOverlapping(
  MultiPoint first,
  MultiPoint second,
) {
  for (final firstPoint in first.coordinates) {
    for (final secondPoint in second.coordinates) {
      if (firstPoint == secondPoint) {
        return true;
      }
    }
  }
  return false;
}
