// TODO implement https://github.com/Turfjs/turf/blob/fcdaa939c905e6cfa80cca11a0e7cbb851ad1a47/packages/turf-meta/index.js#L886
// TODO implement https://github.com/Turfjs/turf/blob/fcdaa939c905e6cfa80cca11a0e7cbb851ad1a47/packages/turf-meta/index.js#L1001
import 'geojson.dart';
import 'invariant.dart';
import 'meta.dart';

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

FeatureCollection<LineString> lineSegment(GeoJSONObject geoJson) {
  List<Feature<LineString>> features = [];
  segmentEach(geoJson, (currentSegment, featureIndex, multiFeatureIndex,
      geometryIndex, segmentIndex) {
    features.add(currentSegment);
  });
  return FeatureCollection(features: features);
}

/// SegmentEachCallback
typedef dynamic SegmentEachCallback(
    Feature<LineString> currentSegment,
    int featureIndex,
    int multiFeatureIndex,
    int? geometryIndex,
    int segmentIndex);

/// Iterates over 2-vertex line segment in any GeoJSON object, similar to Array.forEach()
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

void segmentEach(GeoJSONObject geoJson, SegmentEachCallback callback) {
  flattenEach(geoJson,
      (Feature feature, int featureIndex, int multiFeatureIndex) {
    var segmentIndex = 0;

    if (geoJson is Point) {
      return false;
    }
    // Generate 2-vertex line segments
    Position? previousCoord;
    int previousFeatureIndex = 0;
    int previousMultiIndex = 0;
    int prevGeomIndex = 0;
    coordEach(feature, (Position? currentCoord, int? coordIndex,
        int? featureIndexCoord, int? multiPartIndexCoord, int? geometryIndex) {
      // Simulating a meta.coordReduce() since `reduce` operations cannot be stopped by returning `false`
      if (previousCoord == null ||
          featureIndex > previousFeatureIndex ||
          (multiPartIndexCoord ?? 0) > previousMultiIndex ||
          (geometryIndex ?? 0) > prevGeomIndex) {
        previousCoord = currentCoord;
        previousFeatureIndex = featureIndex;
        previousMultiIndex = multiPartIndexCoord ?? 0;
        prevGeomIndex = geometryIndex ?? 0;
        segmentIndex = 0;
        return false;
      }
      var currentSegment = Feature(
          bbox: previousCoord != null
              ? BBox.named(
                  lat1: previousCoord!.lat,
                  lat2: currentCoord!.lat,
                  lng1: previousCoord!.lng,
                  lng2: currentCoord.lng)
              : null,
          geometry: LineString(coordinates: [previousCoord!, currentCoord!]),
          properties: Map<String, dynamic>.of(feature.properties ?? {}));
      if (callback(currentSegment, featureIndex, multiFeatureIndex,
              geometryIndex, segmentIndex) ==
          false) return false;
      segmentIndex++;
      previousCoord = currentCoord;
    });
  });
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
