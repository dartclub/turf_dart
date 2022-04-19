import 'package:turf/src/meta/coord.dart';
import 'package:turf/src/meta/flatten.dart';

import 'geojson.dart';

/// Creates a [FeatureCollection] of 2-vertex [LineString] segments from a
/// [LineString] or [MultiLineString] or [Polygon] and [MultiPolygon]
/// Returns [FeatureCollection<LineString>] 2-vertex line segments
/// For example:
///
/// ```dart
/// var polygon = Polygon.fromJson({
///     'coordinates': [
///       [
///         [0, 0],
///         [1, 1],
///         [0, 1],
///         [0, 0],
///       ],
///     ];
/// var segments = lineSegment(polygon);
/// //addToMap
/// var addToMap = [polygon, segments]

FeatureCollection<LineString> lineSegment(GeoJSONObject geoJson,
    {bool combineGeometries = false}) {
  List<Feature<LineString>> features = [];
  segmentEach(
    geoJson,
    (currentSegment, featureIndex, multiFeatureIndex, geometryIndex,
        segmentIndex) {
      features.add(currentSegment);
    },
    combineNestedGeometries: combineGeometries,
  );
  return FeatureCollection(features: features);
}

/// SegmentEachCallback
typedef SegmentEachCallback = dynamic Function(
  Feature<LineString> currentSegment,
  int featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
  int segmentIndex,
);

/// Iterates over 2-vertex line segment in any GeoJSON object, similar to [Iterable.forEach]
/// (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
///
/// Takes [FeatureCollection],[Feature] or [GeometryObject] geojson any GeoJSON
/// a [SegmentEachCallback] method that takes (currentSegment, featureIndex, multiFeatureIndex, geometryIndex, segmentIndex),
/// and a [combineNestedGeometries] flag that connects [Polygon]'s geometries with each other.
/// For example:
///
/// ```dart
/// var polygon = Polygon(coordinates: [
///      [
///        Position.of([0, 0]),
///        Position.of([1, 1]),
///       Position.of([0, 1]),
///        Position.of([0, 0]),
///      ],
///    ]),
/// ```
/// Iterates over GeoJSON by 2-vertex segments
/// segmentEach(polygon, (currentSegment, featureIndex, multiFeatureIndex, geometryIndex, segmentIndex) {
///   //=currentSegment
///   //=featureIndex
///   //=multiFeatureIndex
///   //=geometryIndex
///   //=segmentIndex
/// });
///
/// // Calculate the total number of segments
/// var total = 0;
/// turf.segmentEach(polygon, function () {
///     total++;
/// });
///
///
///
///

void segmentEach(
  GeoJSONObject geojson,
  SegmentEachCallback callback, {
  bool combineNestedGeometries = true,
}) {
  int segmentIndex = 0;
  flattenEach(
    geojson,
    (Feature<GeometryType> currentFeature, int featureIndex,
        int multiFeatureIndex) {
      var geometry = currentFeature.geometry;

      if (geometry is Point) {
        return false;
      }

      if (geometry != null && combineNestedGeometries) {
        segmentIndex = _segmentEachforEachUnit(
          geometry,
          callback,
          currentFeature.properties,
          featureIndex,
          multiFeatureIndex,
          segmentIndex,
        );
      } else {
        List<List<Position>> coords = [];
        if (geometry is Polygon) {
          coords = geometry.coordinates;
        }
        if (geometry is LineString) {
          coords.add(geometry.coordinates);
        }

        for (int i = 0; i < coords.length; i++) {
          var line = LineString(coordinates: coords[i]);

          segmentIndex = _segmentEachforEachUnit(
            line,
            callback,
            currentFeature.properties,
            featureIndex,
            multiFeatureIndex,
            segmentIndex,
          );
        }
      }
    },
  );
}

int _segmentEachforEachUnit(
  GeometryType geometry,
  SegmentEachCallback callback,
  Map<String, dynamic>? currentProperties,
  int featureIndex,
  int multiFeatureIndex,
  int segmentIndex,
) {
  coordReduce<Position>(
    geometry,
    (
      previousCoord,
      currentCoord,
      coordIndex,
      featureIndex2,
      multiFeatureIndex2,
      geometryIndex,
    ) {
      Feature<LineString> segment = Feature<LineString>(
        id: segmentIndex,
        geometry: LineString(coordinates: [previousCoord!, currentCoord!]),
        properties: Map.of(currentProperties ?? {}),
        bbox: BBox.named(
          lat1: previousCoord.lat,
          lat2: currentCoord.lat,
          lng1: previousCoord.lng,
          lng2: currentCoord.lng,
        ),
      );
      callback(
        segment,
        featureIndex,
        multiFeatureIndex,
        geometryIndex,
        segmentIndex,
      );
      segmentIndex++;
      return currentCoord;
    },
    null,
  );
  return segmentIndex;
}

/// Callback for segmentReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an [initialValue] argument.
///
/// If an [initialValue] is provided to the reduce method:
///  - The [previousValue] argument is initialValue.
///  - The [currentValue] argument is the value of the first element present in the [List].
///
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in the [List].
///  - The [currentValue] argument is the value of the second element present in the [List].
///
/// SegmentReduceCallback
/// [previousValue] The accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied.
/// [Feature<LineString>] [currentSegment] The current Segment being processed.
/// [featureIndex] The current index of the Feature being processed.
/// [multiFeatureIndex] The current index of the Multi-Feature being processed.
/// [geometryIndex] The current index of the Geometry being processed.
/// [segmentIndex] The current index of the Segment being processed.
typedef SegmentReduceCallback<T> = T? Function(
  T? previousValue,
  Feature<LineString> currentSegment,
  T? initialValue,
  int featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
  int segmentIndex,
);

/// Reduces 2-vertex line segment in any GeoJSON object, similar to [Iterable.reduce]()
/// (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
///
/// Takes [FeatureCollection], [Feature], [GeoJSONObject], a
/// [SegmentReduceCallback] method that takes (previousValue, currentSegment, currentIndex), an
/// [initialValue] value to use as the first argument to the first call of the callback.
///
/// Iterates over [GeoJSONObject] by 2-vertex segments
/// For example:
///
/// ```dart
/// var polygon =Polygon(coordinates: [
///      [
///        Position.of([0, 0]),
///        Position.of([1, 1]),
///       Position.of([0, 1]),
///        Position.of([0, 0]),
///      ],
///    ]),
///
/// segmentReduce(polygon, (previousSegment, currentSegment, featureIndex, multiFeatureIndex, geometryIndex, segmentIndex) {
///   //= previousSegment
///   //= currentSegment
///   //= featureIndex
///   //= multiFeatureIndex
///   //= geometryIndex
///   //= segmentIndex
///   return currentSegment
/// });
///
/// // Calculate the total number of segments
/// var total = segmentReduce(polygon, (previousValue) {
///     previousValue++;
///     return previousValue;
/// }, 0);
/// ```

T? segmentReduce<T>(
  GeoJSONObject geojson,
  SegmentReduceCallback<T> callback,
  T? initialValue, {
  bool combineNestedGeometries = true,
}) {
  T? previousValue = initialValue;
  var started = false;
  segmentEach(
    geojson,
    (currentSegment, featureIndex, multiFeatureIndex, geometryIndex,
        segmentIndex) {
      if (started == false && initialValue == null && initialValue is T) {
        previousValue = currentSegment.clone() as T;
      } else {
        previousValue = callback(previousValue, currentSegment, initialValue,
            featureIndex, multiFeatureIndex, geometryIndex, segmentIndex);
      }
      started = true;
    },
    combineNestedGeometries: combineNestedGeometries,
  );
  return previousValue;
}
