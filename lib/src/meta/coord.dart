import 'package:turf/helpers.dart';
import 'package:turf/src/meta/geom.dart';
import 'package:turf/src/meta/short_circuit.dart';

typedef CoordEachCallback = dynamic Function(
  Position? currentCoord,
  int? coordIndex,
  int? featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
);

typedef LocalizedCoordEachCallback = dynamic Function(
  Position? currentCoord,
  int? coordIndex,
  int? featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
  int? localCoordIndex,
);

dynamic _callbackWrapper(
    Function callback, Position? currentCoord, _IndexCounter counter) {
  if (callback is CoordEachCallback) {
    return callback(
      currentCoord,
      counter.coordIndex,
      counter.featureIndex,
      counter.multiFeatureIndex,
      counter.geometryIndex,
    );
  } else if (callback is LocalizedCoordEachCallback) {
    return callback(
      currentCoord,
      counter.coordIndex,
      counter.featureIndex,
      counter.multiFeatureIndex,
      counter.geometryIndex,
      counter.localCoordIndex,
    );
  } else {
    throw Exception('Unknown callback type');
  }
}

/// Iterates over coordinates in any [geoJSONObject], similar to [Iterable.forEach]
/// example:
/// ```dart
/// var features = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position.of([26, 37])), properties: {'foo': 'bar'}),
///   Feature(geometry: Point(coordinates: Position.of([36, 53])), properties: {'foo': 'bar'})
/// ]);
///
/// coordEach(features, (currentCoord, coordIndex, featureIndex, multiFeatureIndex, geometryIndex) {
///  //=currentCoord
///  //=coordIndex
///  //=featureIndex
///  //=multiFeatureIndex
///  //=geometryIndex
/// });
/// ```
void coordEach(GeoJSONObject geoJSON, Function callback,
    [bool excludeWrapCoord = false]) {
  _IndexCounter indexCounter = _IndexCounter();
  try {
    geomEach(
      geoJSON,
      (
        GeometryType? currentGeometry,
        int? featureIndex,
        featureProperties,
        featureBBox,
        featureId,
      ) {
        if (currentGeometry == null) return;

        indexCounter.featureIndex = featureIndex ?? 0;

        _forEachCoordInGeometryObject(
            currentGeometry, callback, excludeWrapCoord, indexCounter);
      },
    );
  } on ShortCircuit {
    return;
  }
}

void _forEachCoordInGeometryObject(GeometryType geometry, Function callback,
    bool excludeWrapCoord, _IndexCounter indexCounter) {
  GeoJSONObjectType geomType = geometry.type;
  int wrapShrink = excludeWrapCoord &&
          (geomType == GeoJSONObjectType.polygon ||
              geomType == GeoJSONObjectType.multiPolygon)
      ? 1
      : 0;
  indexCounter.multiFeatureIndex = 0;

  var coords = geometry.coordinates;
  if (geomType == GeoJSONObjectType.point) {
    _forEachCoordInPoint(coords, callback, indexCounter);
  } else if (geomType == GeoJSONObjectType.lineString ||
      geomType == GeoJSONObjectType.multiPoint) {
    _forEachCoordInCollection(coords, geomType, callback, indexCounter);
  } else if (geomType == GeoJSONObjectType.polygon ||
      geomType == GeoJSONObjectType.multiLineString) {
    _forEachCoordInNestedCollection(
        coords, geomType, wrapShrink, callback, indexCounter);
  } else if (geomType == GeoJSONObjectType.multiPolygon) {
    _forEachCoordInMultiNestedCollection(
        coords, geomType, wrapShrink, callback, indexCounter);
  } else {
    throw Exception('Unknown Geometry Type');
  }
}

void _forEachCoordInMultiNestedCollection(coords, GeoJSONObjectType geomType,
    int wrapShrink, Function callback, _IndexCounter indexCounter) {
  for (var j = 0; j < coords.length; j++) {
    indexCounter.geometryIndex = 0;
    for (var k = 0; k < coords[j].length; k++) {
      indexCounter.localCoordIndex = 0;
      for (var l = 0; l < coords[j][k].length - wrapShrink; l++) {
        if (_callbackWrapper(callback, coords[j][k][l], indexCounter) ==
            false) {
          throw ShortCircuit();
        }
        indexCounter.coordIndex++;
        indexCounter.localCoordIndex++;
      }
      indexCounter.geometryIndex++;
    }
    indexCounter.multiFeatureIndex++;
  }
}

void _forEachCoordInNestedCollection(coords, GeoJSONObjectType geomType,
    int wrapShrink, Function callback, _IndexCounter indexCounter) {
  for (var j = 0; j < coords.length; j++) {
    indexCounter.localCoordIndex = 0;
    for (var k = 0; k < coords[j].length - wrapShrink; k++) {
      if (_callbackWrapper(callback, coords[j][k], indexCounter) == false) {
        throw ShortCircuit();
      }
      indexCounter.coordIndex++;
      indexCounter.localCoordIndex++;
    }
    if (geomType == GeoJSONObjectType.multiLineString) {
      indexCounter.multiFeatureIndex++;
    }
    if (geomType == GeoJSONObjectType.polygon) {
      indexCounter.geometryIndex++;
    }
  }
  if (geomType == GeoJSONObjectType.polygon) {
    indexCounter.multiFeatureIndex++;
  }
}

void _forEachCoordInCollection(coords, GeoJSONObjectType geomType,
    Function callback, _IndexCounter indexCounter) {
  indexCounter.localCoordIndex = 0;
  for (var j = 0; j < coords.length; j++) {
    if (_callbackWrapper(callback, coords[j], indexCounter) == false) {
      throw ShortCircuit();
    }
    indexCounter.coordIndex++;
    indexCounter.localCoordIndex++;
    if (geomType == GeoJSONObjectType.multiPoint) {
      indexCounter.multiFeatureIndex++;
    }
  }
  if (geomType == GeoJSONObjectType.lineString) {
    indexCounter.multiFeatureIndex++;
  }
}

void _forEachCoordInPoint(
    Position coords, Function callback, _IndexCounter indexCounter) {
  indexCounter.localCoordIndex = 0;
  if (_callbackWrapper(callback, coords, indexCounter) == false) {
    throw ShortCircuit();
  }
  indexCounter.localCoordIndex++;
  indexCounter.coordIndex++;
  indexCounter.multiFeatureIndex++;
}

/// A simple class to manage counters from CoordinateEach functions
class _IndexCounter {
  int localCoordIndex = 0;
  int coordIndex = 0;
  int geometryIndex = 0;
  int multiFeatureIndex = 0;
  int featureIndex = 0;
}

/// Callback for coordReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an initialValue argument.
///
/// If an [initialValue] is provided to the reduce method:
///  - The [previousValue] argument is initialValue.
///  - The [currentValue] argument is the value of the first element present in the [List].
///
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in the [List].
///  - The [currentValue] argument is the value of the second element present in the [List].
///
/// Takes [previousValue], the accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied,
/// [Position][currentCoord] The current coordinate being processed, [coordIndex]
/// The current index of the coordinate being processed. Starts at index 0, if an
/// initialValue is provided, and at index 1 otherwise, [featureIndex] The current
/// index of the Feature being processed, [multiFeatureIndex], the current index
/// of the Multi-Feature being processed., and [geometryIndex], the current index of the Geometry being processed.
typedef CoordReduceCallback<T> = T? Function(
  T? previousValue, // todo: change to CoordType
  Position? currentCoord,
  int? coordIndex,
  int? featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
);

/// Reduces coordinates in any [GeoJSONObject], similar to [Iterable.reduce]
///
/// Takes [FeatureCollection], [GeometryObject], or a [Feature],
/// a [CoordReduceCallback] method that takes (previousValue, currentCoord, coordIndex), an
/// [initialValue] Value to use as the first argument to the first call of the callback,
/// and a boolean [excludeWrapCoord=false] for whether or not to include the final coordinate
/// of LinearRings that wraps the ring in its iteration.
/// Returns the value that results from the reduction.
/// For example:
///
/// ```dart
/// var features = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position.of([26, 37])), properties: {'foo': 'bar'}),
///   Feature(geometry: Point(coordinates: Position.of([36, 53])), properties: {'foo': 'bar'})
/// ]);
///
/// coordReduce(features, (previousValue, currentCoord, coordIndex, featureIndex, multiFeatureIndex, geometryIndex) {
///   //=previousValue
///   //=currentCoord
///   //=coordIndex
///   //=featureIndex
///   //=multiFeatureIndex
///   //=geometryIndex
///   return currentCoord;
/// });

T? coordReduce<T>(
  GeoJSONObject geojson,
  CoordReduceCallback<T> callback,
  T? initialValue, [
  bool excludeWrapCoord = false,
]) {
  var previousValue = initialValue;
  coordEach(geojson, (Position? currentCoord, coordIndex, featureIndex,
      multiFeatureIndex, geometryIndex) {
    if (coordIndex == 0 && initialValue == null && currentCoord is T) {
      previousValue = currentCoord?.clone() as T;
    } else {
      previousValue = callback(previousValue, currentCoord, coordIndex,
          featureIndex, multiFeatureIndex, geometryIndex);
    }
  }, excludeWrapCoord);
  return previousValue;
}

/// Gets all coordinates from any [GeoJSONObject].
/// Receives any [GeoJSONObject]
/// Returns [List<Position>]
/// For example:
///
/// ```dart
/// var featureColl = FeatureCollection(features:
/// [Feature(geometry: Point(coordinates: Position(13,15)))
/// ,Feature(geometry: LineString(coordinates: [Position(1, 2),
/// Position(67, 50)]))]);
///
/// var coords = coordAll(features);
/// //= [Position(13,15), Position(1, 2), Position(67, 50)]
List<Position?> coordAll(GeoJSONObject geojson) {
  List<Position?> coords = [];
  coordEach(geojson, (
    Position? currentCoord,
    int? coordIndex,
    int? featureIndex,
    int? multiFeatureIndex,
    int? geometryIndex,
  ) {
    coords.add(currentCoord);
  });
  return coords;
}
