import 'package:turf/helpers.dart';
import 'package:turf/src/meta/short_circuit.dart';

/// Utility to extract "other members" from GeoJSON objects
/// according to RFC 7946 specification.
Map<String, dynamic> extractOtherMembers(
    Map<String, dynamic> json, List<String> standardKeys) {
  final otherMembers = <String, dynamic>{};

  json.forEach((key, value) {
    if (!standardKeys.contains(key)) {
      otherMembers[key] = value;
    }
  });

  return otherMembers;
}

/// Storage for other members using Expando to prevent memory leaks
final _otherMembersExpando = Expando<Map<String, dynamic>>('otherMembers');

/// Extension to add "other members" support to GeoJSONObject
/// This follows RFC 7946 specification:
/// "A GeoJSON object MAY have 'other members'. Implementations
/// MUST NOT interpret foreign members as having any meaning unless
/// part of an extension or profile."
extension GeoJSONObjectOtherMembersExtension on GeoJSONObject {
  /// Get other members for this GeoJSON object
  Map<String, dynamic> get otherMembers {
    return _otherMembersExpando[this] ?? {};
  }

  /// Set other members for this GeoJSON object
  void setOtherMembers(Map<String, dynamic> members) {
    _otherMembersExpando[this] = Map<String, dynamic>.from(members);
  }

  /// Merge additional other members with existing ones
  void mergeOtherMembers(Map<String, dynamic> newMembers) {
    final current = Map<String, dynamic>.from(otherMembers);
    current.addAll(newMembers);
    setOtherMembers(current);
  }

  /// Convert to JSON with other members included
  /// This is the compliant serialization method that includes other members
  /// as per RFC 7946 specification.
  Map<String, dynamic> toJsonWithOtherMembers() {
    final json = toJson();
    final others = otherMembers;

    if (others.isNotEmpty) {
      json.addAll(others);
    }

    return json;
  }

  /// Clone with other members preserved
  T clonePreservingOtherMembers<T extends GeoJSONObject>() {
    final clone = this.clone() as T;
    clone.setOtherMembers(otherMembers);
    return clone;
  }

  /// CopyWith method that preserves other members
  /// This is used to create a new GeoJSONObject with some properties modified
  /// while preserving all other members
  GeoJSONObject copyWithPreservingOtherMembers() {
    return clonePreservingOtherMembers();
  }
}

/// Extension to add "other members" support specifically to Feature
extension FeatureOtherMembersExtension on Feature {
  /// Standard keys for Feature objects as per GeoJSON specification
  static const standardKeys = ['type', 'geometry', 'properties', 'id', 'bbox'];

  /// Create a Feature from JSON with support for other members
  static Feature fromJsonWithOtherMembers(Map<String, dynamic> json) {
    final feature = Feature.fromJson(json);

    // Extract other members
    final otherMembers = extractOtherMembers(json, standardKeys);
    if (otherMembers.isNotEmpty) {
      feature.setOtherMembers(otherMembers);
    }

    return feature;
  }

  /// Create a new Feature with modified properties while preserving other members
  Feature<T> copyWithPreservingOtherMembers<T extends GeometryObject>({
    T? geometry,
    Map<String, dynamic>? properties,
    BBox? bbox,
    dynamic id,
  }) {
    final newFeature = Feature<T>(
      geometry: geometry ?? this.geometry as T,
      properties: properties ?? this.properties,
      bbox: bbox ?? this.bbox,
      id: id ?? this.id,
    );

    newFeature.setOtherMembers(otherMembers);
    return newFeature;
  }
}

/// Extension to add "other members" support specifically to FeatureCollection
extension FeatureCollectionOtherMembersExtension on FeatureCollection {
  /// Standard keys for FeatureCollection objects as per GeoJSON specification
  static const standardKeys = ['type', 'features', 'bbox'];

  /// Create a FeatureCollection from JSON with support for other members
  static FeatureCollection fromJsonWithOtherMembers(Map<String, dynamic> json) {
    final featureCollection = FeatureCollection.fromJson(json);

    // Extract other members
    final otherMembers = extractOtherMembers(json, standardKeys);
    if (otherMembers.isNotEmpty) {
      featureCollection.setOtherMembers(otherMembers);
    }

    return featureCollection;
  }

  /// Create a new FeatureCollection with modified properties while preserving other members
  FeatureCollection<T>
      copyWithPreservingOtherMembers<T extends GeometryObject>({
    List<Feature<T>>? features,
    BBox? bbox,
  }) {
    final newFeatureCollection = FeatureCollection<T>(
      features: features ?? this.features.cast<Feature<T>>(),
      bbox: bbox ?? this.bbox,
    );

    newFeatureCollection.setOtherMembers(otherMembers);
    return newFeatureCollection;
  }
}

/// Extension to add "other members" support specifically to GeometryObject
extension GeometryObjectOtherMembersExtension on GeometryObject {
  /// Standard keys for GeometryObject as per GeoJSON specification
  static const standardKeys = ['type', 'coordinates', 'geometries', 'bbox'];

  /// Create a GeometryObject from JSON with support for other members
  static GeometryObject fromJsonWithOtherMembers(Map<String, dynamic> json) {
    final geometryObject = GeometryObject.deserialize(json);

    // Extract other members
    final otherMembers = extractOtherMembers(json, standardKeys);
    if (otherMembers.isNotEmpty) {
      geometryObject.setOtherMembers(otherMembers);
    }

    return geometryObject;
  }

  /// Create a new GeometryObject with modified properties while preserving other members
  GeometryObject copyWithPreservingOtherMembers({
    BBox? bbox,
  }) {
    GeometryObject newObject;

    // Handle the different geometry types
    if (this is Point) {
      final point = this as Point;
      newObject = Point(
        coordinates: point.coordinates,
        bbox: bbox ?? point.bbox,
      );
    } else if (this is MultiPoint) {
      final multiPoint = this as MultiPoint;
      newObject = MultiPoint(
        coordinates: multiPoint.coordinates,
        bbox: bbox ?? multiPoint.bbox,
      );
    } else if (this is LineString) {
      final lineString = this as LineString;
      newObject = LineString(
        coordinates: lineString.coordinates,
        bbox: bbox ?? lineString.bbox,
      );
    } else if (this is MultiLineString) {
      final multiLineString = this as MultiLineString;
      newObject = MultiLineString(
        coordinates: multiLineString.coordinates,
        bbox: bbox ?? multiLineString.bbox,
      );
    } else if (this is Polygon) {
      final polygon = this as Polygon;
      newObject = Polygon(
        coordinates: polygon.coordinates,
        bbox: bbox ?? polygon.bbox,
      );
    } else if (this is MultiPolygon) {
      final multiPolygon = this as MultiPolygon;
      newObject = MultiPolygon(
        coordinates: multiPolygon.coordinates,
        bbox: bbox ?? multiPolygon.bbox,
      );
    } else if (this is GeometryCollection) {
      final collection = this as GeometryCollection;
      newObject = GeometryCollection(
        geometries: collection.geometries,
        bbox: bbox ?? collection.bbox,
      );
    } else {
      // Fallback - just clone with proper casting
      newObject = clone() as GeometryObject;
    }

    newObject.setOtherMembers(otherMembers);
    return newObject;
  }
}

typedef GeomEachCallback = dynamic Function(
  GeometryType? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties,
  BBox? featureBBox,
  dynamic featureId,
);

/// Iterates over each geometry in [geoJSON], calling [callback] on each
/// iteration. Similar to [Iterable.forEach]
///
/// For example:
///
/// ```dart
/// FeatureCollection featureCollection = FeatureCollection(
///   features: [
///     point1,
///     point2,
///     point3,
///   ],
/// );
/// geomEach(featureCollection, (currentGeometry, featureIndex, featureProperties, featureBBox, featureId) {
///   someOperationOnEachPoint(currentGeometry);
/// });
/// ```
void geomEach(GeoJSONObject geoJSON, GeomEachCallback callback) {
  try {
    if (geoJSON is FeatureCollection) {
      _forEachGeomInFeatureCollection(geoJSON, callback);
    } else if (geoJSON is Feature) {
      _forEachGeomInFeature(geoJSON, callback, 0);
    } else if (geoJSON is GeometryObject) {
      _forEachGeomInGeometryObject(geoJSON, callback, {}, null, null, 0);
    } else {
      throw Exception('Unknown Geometry Type');
    }
  } on ShortCircuit {
    return;
  }
}

void _forEachGeomInFeatureCollection(
    FeatureCollection featureCollection, GeomEachCallback callback) {
  int featuresLength = featureCollection.features.length;
  for (int featureIndex = 0; featureIndex < featuresLength; featureIndex++) {
    _forEachGeomInFeature(
        featureCollection.features[featureIndex], callback, featureIndex);
  }
}

void _forEachGeomInFeature(Feature<GeometryObject> feature,
    GeomEachCallback callback, int featureIndex) {
  _forEachGeomInGeometryObject(feature.geometry, callback, feature.properties,
      feature.bbox, feature.id, featureIndex);
}

void _forEachGeomInGeometryObject(
    GeometryObject? geometryObject,
    GeomEachCallback callback,
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    dynamic featureId,
    int featureIndex) {
  if (geometryObject is GeometryType) {
    if (callback(
          geometryObject,
          featureIndex,
          featureProperties,
          featureBBox,
          featureId,
        ) ==
        false) {
      throw ShortCircuit();
    }
  } else if (geometryObject is GeometryCollection) {
    int geometryCollectionLength = geometryObject.geometries.length;

    for (int geometryIndex = 0;
        geometryIndex < geometryCollectionLength;
        geometryIndex++) {
      _forEachGeomInGeometryObject(
        geometryObject.geometries[geometryIndex],
        callback,
        featureProperties,
        featureBBox,
        featureId,
        featureIndex,
      );
    }
  } else {
    throw Exception('Unknown Geometry Type');
  }
}

/// Callback for geomReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an [initialValue] argument.
///
/// If an initialValue is provided to the reduce method:
///  - The [previousValue] argument is [initialValue].
///  - The [currentValue] argument is the value of the first element present in the [List].
///
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in the [List].
///  - The [currentGeometry] argument is the value of the second element present in the [List].
typedef GeomReduceCallback<T> = T? Function(
  T? previousValue,
  GeometryType? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties,
  BBox? featureBBox,
  dynamic featureId,
);

/// Reduces geometry in any [GeoJSONObject], similar to [Iterable.reduce].
///
/// Takes [FeatureCollection], [Feature] or [GeometryObject], a [GeomReduceCallback] method
/// that takes (previousValue, currentGeometry, featureIndex, featureProperties, featureBBox, featureId) and
/// an [initialValue] Value to use as the first argument to the first call of the callback.
/// Returns the value that results from the reduction.
/// For example:
///
/// ```dart
/// var features = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position.of([26, 37])), properties: {'foo': 'bar'}),
///   Feature(geometry: Point(coordinates: Position.of([36, 53])), properties: {'foo': 'bar'})
/// ]);
///
/// geomReduce(features, (previousValue, currentGeometry, featureIndex, featureProperties, featureBBox, featureId) {
///   //=previousValue
///   //=currentGeometry
///   //=featureIndex
///   //=featureProperties
///   //=featureBBox
///   //=featureId
///   return currentGeometry
/// });
/// ```

T? geomReduce<T>(
  GeoJSONObject geoJSON,
  GeomReduceCallback<T> callback,
  T? initialValue,
) {
  T? previousValue = initialValue;
  geomEach(
    geoJSON,
    (
      currentGeometry,
      featureIndex,
      featureProperties,
      featureBBox,
      featureId,
    ) {
      if (previousValue == null && featureIndex == 0 && currentGeometry is T) {
        previousValue = currentGeometry?.clone() as T;
      } else {
        previousValue = callback(
          previousValue,
          currentGeometry,
          featureIndex,
          featureProperties,
          featureBBox,
          featureId,
        );
      }
    },
  );
  return previousValue;
}
