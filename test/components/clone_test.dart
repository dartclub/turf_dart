import 'package:test/test.dart';
import 'package:turf/clone.dart'; // Adjust path to where your `clone` function lives

void main() {
  group('GeoJSON clone tests', () {
    test('Clones a simple Point feature', () {
      final input = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [102.0, 0.5]
        },
        "properties": {"prop0": "value0"}
      };

      final result = clone(input);

      expect(result, equals(input));
      expect(identical(result, input), isFalse); // Ensure it's a deep clone
    });

    test('Clones a LineString feature with properties', () {
      final input = {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [102.0, 0.0],
            [103.0, 1.0],
            [104.0, 0.0],
            [105.0, 1.0]
          ]
        },
        "properties": {"stroke": "blue", "opacity": 0.6}
      };

      final result = clone(input);

      expect(result, equals(input));
      expect(result['properties'], isNot(same(input['properties'])));
    });

    test('Clones a FeatureCollection', () {
      final input = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [102.0, 0.5]
            },
            "properties": {"prop0": "value0"}
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "LineString",
              "coordinates": [
                [102.0, 0.0],
                [103.0, 1.0]
              ]
            },
            "properties": {"prop1": "value1"}
          }
        ]
      };

      final result = clone(input);

      expect(result, equals(input));
      expect(result['features'][0], isNot(same(input['features'][0])));
    });

    test('Clones a GeometryCollection', () {
      final input = {
        "type": "GeometryCollection",
        "geometries": [
          {
            "type": "Point",
            "coordinates": [100.0, 0.0]
          },
          {
            "type": "LineString",
            "coordinates": [
              [101.0, 0.0],
              [102.0, 1.0]
            ]
          }
        ]
      };

      final result = clone(input);

      expect(result, equals(input));
      expect(result['geometries'][1], isNot(same(input['geometries'][1])));
    });

    test('Throws error for null input', () {
      expect(() => clone(null), throwsArgumentError);
    });

    test('Throws error for unknown GeoJSON type', () {
      final input = {
        "type": "UnknownThing",
        "data": []
      };

      expect(() => clone(input), throwsArgumentError);
    });
  });
}
