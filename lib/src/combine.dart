import 'package:turf/meta.dart';

/// Combines a [FeatureCollection] of [Point], [LineString], or [Polygon] features
/// (and their Multi* counterparts) into [MultiPoint], [MultiLineString], or
/// [MultiPolygon] features.
///
/// Features may be mixed: each non-empty geometry kind becomes one output feature.
/// Other geometry types and features with null geometry are skipped.
///
/// Returns a [FeatureCollection] with up to three features, in Turf JS order:
/// MultiLineString, then MultiPoint, then MultiPolygon (only groups that have
/// coordinates are included).
///
/// Each output feature has `properties.collectedProperties`, a list of the
/// source features' `properties` values (one entry per contributing feature;
/// for a Multi* input, one entry applies to all coordinates merged from that feature).
///
/// See: https://turfjs.org/docs/#combine
FeatureCollection<GeometryObject> combine(FeatureCollection collection) {
  // Buckets mirror @turf/combine: coordinates + parallel property list per group.
  final multiPointCoords = <Position>[];
  final multiPointProps = <Map<String, dynamic>?>[];

  final multiLineCoords = <List<Position>>[];
  final multiLineProps = <Map<String, dynamic>?>[];

  final multiPolyCoords = <List<List<Position>>>[];
  final multiPolyProps = <Map<String, dynamic>?>[];

  // Walk input; flatten Multi* into the same bucket as their single counterparts.
  featureEach(collection, (currentFeature, _) {
    final geometry = currentFeature.geometry;
    if (geometry == null) {
      return;
    }
    final Map<String, dynamic>? props = currentFeature.properties;

    if (geometry is Point) {
      multiPointCoords.add(geometry.coordinates);
      multiPointProps.add(props);
    } else if (geometry is MultiPoint) {
      multiPointCoords.addAll(geometry.coordinates);
      multiPointProps.add(props);
    } else if (geometry is LineString) {
      multiLineCoords.add(geometry.coordinates);
      multiLineProps.add(props);
    } else if (geometry is MultiLineString) {
      multiLineCoords.addAll(geometry.coordinates);
      multiLineProps.add(props);
    } else if (geometry is Polygon) {
      multiPolyCoords.add(geometry.coordinates);
      multiPolyProps.add(props);
    } else if (geometry is MultiPolygon) {
      multiPolyCoords.addAll(geometry.coordinates);
      multiPolyProps.add(props);
    }
  });

  // Emit one Feature per non-empty group (same key order as Object.keys(...).sort() in Turf).
  final features = <Feature<GeometryObject>>[];

  if (multiLineCoords.isNotEmpty) {
    features.add(
      Feature<GeometryObject>(
        geometry: MultiLineString(coordinates: multiLineCoords),
        properties: <String, dynamic>{'collectedProperties': multiLineProps},
      ),
    );
  }
  if (multiPointCoords.isNotEmpty) {
    features.add(
      Feature<GeometryObject>(
        geometry: MultiPoint(coordinates: multiPointCoords),
        properties: <String, dynamic>{'collectedProperties': multiPointProps},
      ),
    );
  }
  if (multiPolyCoords.isNotEmpty) {
    features.add(
      Feature<GeometryObject>(
        geometry: MultiPolygon(coordinates: multiPolyCoords),
        properties: <String, dynamic>{'collectedProperties': multiPolyProps},
      ),
    );
  }

  return FeatureCollection<GeometryObject>(features: features);
}
