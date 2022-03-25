import 'package:turf/meta.dart';

import 'geojson.dart';

// export default lineSegment;

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
    combineGeometries: combineGeometries,
  );
  return FeatureCollection(features: features);
}

/// SegmentEachCallback
typedef dynamic SegmentEachCallback(
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
/// @param {Function} callback a method that takes (currentSegment, featureIndex, multiFeatureIndex, geometryIndex, segmentIndex)
/// @returns {void}
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

void segmentEach(
  GeoJSONObject geojson,
  SegmentEachCallback callback, {
  bool combineGeometries = true,
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

      if (geometry != null && combineGeometries) {
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
/// on whether the reduce method has an initialValue argument.
///
/// If an initialValue is provided to the reduce method:
///  - The previousValue argument is initialValue.
///  - The currentValue argument is the value of the first element present in the array.
///
/// If an initialValue is not provided:
///  - The previousValue argument is the value of the first element present in the array.
///  - The currentValue argument is the value of the second element present in the array.
///
/// SegmentReduceCallback
/// [previousValue] The accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied.
/// [Feature<LineString>] currentSegment The current Segment being processed.
/// [featureIndex] The current index of the Feature being processed.
/// [multiFeatureIndex] The current index of the Multi-Feature being processed.
/// geometryIndex The current index of the Geometry being processed.
///  segmentIndex The current index of the Segment being processed.
///
///
/// Reduce 2-vertex line segment in any GeoJSON object, similar to Array.reduce()
/// (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
///
/// @param {FeatureCollection|Feature|Geometry} geojson any GeoJSON
/// @param {Function} callback a method that takes (previousValue, currentSegment, currentIndex)
/// @param {*} [initialValue] Value to use as the first argument to the first call of the callback.
/// @returns {void}
/// @example
/// var polygon = Polygon([[[-50, 5], [-40, -10], [-50, -10], [-40, 5], [-50, 5]]]);
///
/// // Iterates over GeoJSON by 2-vertex segments
/// segmentReduce(polygon, function (previousSegment, currentSegment, featureIndex, multiFeatureIndex, geometryIndex, segmentIndex) {
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
/// var initialValue = 0
/// var total = turf.segmentReduce(polygon, function (previousValue) {
///     previousValue++;
///     return previousValue;
/// }, initialValue);
///
segmentReduce(geojson, callback, initialValue) {
  var previousValue = initialValue;
  var started = false;
  segmentEach(geojson, (currentSegment, featureIndex, multiFeatureIndex,
      geometryIndex, segmentIndex) {
    if (started == false && initialValue == null) {
      previousValue = currentSegment;
    } else {
      previousValue = callback(previousValue, currentSegment, featureIndex,
          multiFeatureIndex, geometryIndex, segmentIndex);
    }
    started = true;
  });
  return previousValue;
}
