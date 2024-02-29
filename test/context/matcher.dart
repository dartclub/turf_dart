import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/geojson.dart';
import 'package:turf_equality/turf_equality.dart';

Matcher equals<T extends GeoJSONObject>(T? expected) => _Equals<T>(expected);

class _Equals<T extends GeoJSONObject> extends Matcher {
  _Equals(this.expected);
  final T? expected;

  @override
  Description describe(Description description) {
    return description.add('is equal');
  }

  @override
  bool matches(actual, Map matchState) {
    if (actual is! GeoJSONObject) return false;

    Equality eq = Equality();
    return eq.compare(actual, expected);
  }
}

Matcher contains(List<Feature> expected) => _Contains(expected);

class _Contains extends Matcher {
  _Contains(this.expected);
  final List<Feature> expected;

  @override
  Description describe(Description description) {
    return description.add('contains');
  }

  @override
  bool matches(actual, Map matchState) {
    if (actual is! FeatureCollection) throw UnimplementedError();

    Equality eq = Equality();

    for (var feature in expected) {
      if (!actual.features.any((f) => eq.compare(f, feature))) {
        return false;
      }
    }
    return true;
  }
}

Matcher length<T extends GeoJSONObject>(int length) => _Length<T>(length);

class _Length<T extends GeoJSONObject> extends Matcher {
  _Length(this.length);
  final int length;

  @override
  Description describe(Description description) {
    return description.add('length is $length');
  }

  @override
  bool matches(actual, Map matchState) {
    if (actual is FeatureCollection) {
      return actual.features.length == length;
    }

    if (actual is GeometryCollection) {
      return actual.geometries.length == length;
    }

    if (actual is MultiPoint) {
      return actual.coordinates.length == length;
    }

    if (actual is MultiPolygon) {
      return actual.coordinates.length == length;
    }

    if (actual is MultiLineString) {
      return actual.coordinates.length == length;
    }

    return false;
  }
}
