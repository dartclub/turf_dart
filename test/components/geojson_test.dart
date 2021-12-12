import 'dart:math';

import 'package:test/test.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

main() {
  group('Coordinate Types:', () {
    test('Position', () {
      _expectArgs(Position pos) {
        expect(pos.lng, 1);
        expect(pos.lat, 2);
        expect(pos.alt, 3);
        expect(pos[0], 1);
        expect(pos[1], 2);
        expect(pos[2], 3);
        expect(pos.length, 3);
        expect(pos.toJson(), [1, 2, 3]);
      }

      var pos1 = Position.named(lng: 1, lat: 2, alt: 3);
      var pos2 = Position.of([1, 2, 3]);
      _expectArgs(pos1);
      _expectArgs(pos2);
    });
    test('Position deserialization', () {
      expect(Position.of([1, 2]).toList(), [1, 2]);
      expect(Position.of([1, 2, 3]).toList(), [1, 2, 3]);

      // test assert length >= 2 && length <= 3
      expect(() => Position.of([1]).toList(), throwsA(isA<AssertionError>()));
      expect(() => Position.of([1, 2, 3, 4]).toList(),
          throwsA(isA<AssertionError>()));
    });

    test('Position vector addition', () {
      expect(Position(1, 2, 3) + Position(1, 2, 3), Position(2, 4, 6));
    });
    test('Position vector subtraction', () {
      expect(Position(1, 2, 3) - Position(1, 2, 3), Position(0, 0, 0));
    });
    test('Position vector dot product', () {
      expect(Position(1, 2, 3).dotProduct(Position(1, 2, 3)),
          (1) + (2 * 2) + (3 * 3));
      expect(Position(1, 2).dotProduct(Position(1, 2)), (1) + (2 * 2));
    });
    test('Position vector cross product', () {
      expect(Position(1, 2, 3) * Position(1, 2, 3), Position(0, 0, 0));
      expect(Position(3, 2, 1) * Position(1, 2, 3), Position(4, -8, 4));
      expect(() => Position(1, 2, 3) * Position(1, 2), throwsA(isException));
    });

    test('BBox', () {
      _expectArgs(BBox bbox) {
        expect(bbox.lng1, 1);
        expect(bbox.lat1, 2);
        expect(bbox.alt1, 3);
        expect(bbox.lng2, 4);
        expect(bbox.lat2, 5);
        expect(bbox.alt2, 6);
        expect(bbox[0], 1);
        expect(bbox[1], 2);
        expect(bbox[2], 3);
        expect(bbox[3], 4);
        expect(bbox[4], 5);
        expect(bbox[5], 6);
        expect(bbox.length, 6);
        expect(bbox.toJson(), [1, 2, 3, 4, 5, 6]);
      }

      var bbox1 =
          BBox.named(lng1: 1, lat1: 2, alt1: 3, lng2: 4, lat2: 5, alt2: 6);
      var bbox2 = BBox.of([1, 2, 3, 4, 5, 6]);
      var bbox3 = BBox(1, 2, 3, 4, 5, 6);
      _expectArgs(bbox1);
      _expectArgs(bbox2);
      _expectArgs(bbox3);

      // test assert length == 4 || length == 6
      expect(() => BBox.of([1, 2, 3]).toList(), throwsA(isA<AssertionError>()));
      expect(() => BBox.of([1, 2, 3, 4, 5]).toList(),
          throwsA(isA<AssertionError>()));
      expect(() => BBox.of([1, 2, 3, 4, 5, 6, 7]).toList(),
          throwsA(isA<AssertionError>()));

      // test 2 dimensional [length == 4]
      var bbox4 = BBox.named(lng1: 1, lat1: 2, lng2: 3, lat2: 4);
      expect(bbox4.lng1, 1);
      expect(bbox4.lat1, 2);
      expect(bbox4.alt1, null);
      expect(bbox4.lng2, 3);
      expect(bbox4.lat2, 4);
      expect(bbox4.alt2, null);
      expect(bbox4[0], 1);
      expect(bbox4[1], 2);
      expect(bbox4[2], 3);
      expect(bbox4[3], 4);
      expect(() => bbox4[4], throwsRangeError);
      expect(() => bbox4[5], throwsRangeError);
      expect(bbox4.length, 4);
      expect(bbox4.toJson(), [1, 2, 3, 4]);

      expect(bbox1.toSigned().isSigned, true);
      expect(bbox1, bbox1.clone());
    });
  });
  group('Longitude normalization:', () {
    var rand = Random();
    _rand() => rand.nextDouble() * (360 * 2) - 360;
    test('Position.toSigned', () {
      for (var i = 0; i < 10; i++) {
        var coord = Position.named(lat: _rand(), lng: _rand(), alt: 0);
        var zeroZero = Position(0, 0);
        var distToCoord = distanceRaw(zeroZero, coord);
        var distToNormalizedCoord = distanceRaw(zeroZero, coord.toSigned());

        expect(coord.toSigned().isSigned, true);

        expect(
          distToCoord.toStringAsFixed(6),
          distToNormalizedCoord.toStringAsFixed(6),
        );
      }
    });

    test('BBox.toSigned', () {
      for (var i = 0; i < 10; i++) {
        var coord = BBox.named(
          lat1: _rand(),
          lat2: _rand(),
          lng1: _rand(),
          lng2: _rand(),
        );
        var zeroZero = Position(0, 0);

        var distToCoord1 = distanceRaw(
            zeroZero, Position.named(lng: coord.lng1, lat: coord.lat1));
        var normalized = coord.toSigned();
        var distToNormalized = distanceRaw(
            zeroZero,
            Position.named(
                lat: normalized.lat1,
                lng: normalized.lng1,
                alt: normalized.alt1));
        expect(
          distToCoord1.toStringAsFixed(6),
          distToNormalized.toStringAsFixed(6),
        );

        var distToCoord2 = distanceRaw(
            zeroZero, Position.named(lng: coord.lng2, lat: coord.lat2));
        var distToNormalized2 = distanceRaw(
            zeroZero,
            Position.named(
                lat: normalized.lat2,
                lng: normalized.lng2,
                alt: normalized.alt2));
        expect(
          distToCoord2.toStringAsFixed(6),
          distToNormalized2.toStringAsFixed(6),
        );
      }
    });
  });

  group('Test Geometry Types:', () {
    test('Point', () {
      var geoJSON = {
        'coordinates': null,
        'type': GeoJSONObjectType.point,
      };
      expect(() => Point.fromJson(geoJSON), throwsA(isA<TypeError>()));

      var point = Point(coordinates: Position(11, 49));

      expect(point, point.clone());
    });

    var geometries = [
      GeoJSONObjectType.multiPoint,
      GeoJSONObjectType.lineString,
      GeoJSONObjectType.multiLineString,
      GeoJSONObjectType.polygon,
      GeoJSONObjectType.multiPolygon,
    ];

    var collection = GeometryCollection.fromJson({
      'type': GeoJSONObjectType.geometryCollection,
      'geometries': geometries
          .map((type) => {
                'coordinates': null,
                'type': type,
              })
          .toList(),
    });
    for (var i = 0; i < geometries.length; i++) {
      test(geometries[i], () {
        expect(geometries[i], collection.geometries[i].type);
        expect(collection.geometries[i].coordinates,
            isNotNull); // kind of unnecessary
        expect(collection.geometries[i].coordinates, isA<List>());
        expect(collection.geometries[i].coordinates, isEmpty);

        var json = collection.geometries[i].toJson();
        for (var key in ['type', 'coordinates']) {
          expect(json.keys, contains(key));
        }
      });
    }
  });
  test('GeometryCollection', () {
    var geoJSON = {
      'type': GeoJSONObjectType.geometryCollection,
      'geometries': null,
    };
    var collection = GeometryCollection.fromJson(geoJSON);
    expect(collection.type, GeoJSONObjectType.geometryCollection);
    expect(collection.geometries, isNotNull); // kind of unnecessary
    expect(collection.geometries, isA<List>());
    expect(collection.geometries, isEmpty);

    var json = collection.toJson();
    for (var key in ['type', 'geometries']) {
      expect(json.keys, contains(key));
    }
  });
  test('Feature', () {
    var geoJSON = {
      'type': GeoJSONObjectType.feature,
      'geometry': null,
    };
    var feature = Feature.fromJson(geoJSON);
    expect(feature.type, GeoJSONObjectType.feature);
    expect(feature.id, isNull); // kind of unnecessary
    expect(feature.geometry, isNull);

    feature.id = 1;
    feature.geometry = Point(coordinates: Position(11, 49));

    var json = feature.toJson();
    for (var key in ['id', 'type', 'geometry', 'properties']) {
      expect(json.keys, contains(key));
    }

    expect(feature, feature.clone());
  });
  test('FeatureCollection', () {
    var geoJSON = {
      'type': GeoJSONObjectType.featureCollection,
      'features': null,
    };
    var collection = FeatureCollection.fromJson(geoJSON);
    expect(collection.type, GeoJSONObjectType.featureCollection);
    expect(collection.features, isNotNull); // kind of unnecessary
    expect(collection.features, isA<List>());
    expect(collection.features, isEmpty);

    var json = collection.toJson();

    for (var key in ['type', 'features']) {
      expect(json.keys, contains(key));
    }
  });

  test('GeometryObject.deserialize enum test', () {
    var geoJSON =
        GeometryCollection(geometries: [Point(coordinates: Position(1, 1, 1))]);
    GeometryObject serialized = GeometryObject.deserialize(geoJSON.toJson());
    expect(serialized, isA<GeometryCollection>());
    expect(serialized.type, GeoJSONObjectType.geometryCollection);
    expect((serialized as GeometryCollection).geometries.first.type,
        GeoJSONObjectType.point);
  });

  test('MultiPoint.fromPoints', () {
    var a =
        MultiPoint.fromPoints(points: [Point(coordinates: Position(1, 2, 3))]);
    expect(a.coordinates.first, Position(1, 2, 3));
  });
  test('LineString.fromPoints', () {
    var a =
        LineString.fromPoints(points: [Point(coordinates: Position(1, 2, 3))]);
    expect(a.coordinates.first, Position(1, 2, 3));
  });
  test('LineString.fromPoints', () {
    var a =
        LineString.fromPoints(points: [Point(coordinates: Position(1, 2, 3))]);
    expect(a.coordinates.first, Position(1, 2, 3));
  });
  test('MultiLineString.fromLineStrings', () {
    var a = MultiLineString.fromLineStrings(lineStrings: [
      LineString.fromPoints(points: [Point(coordinates: Position(1, 2, 3))])
    ]);
    expect(a.coordinates.first.first, Position(1, 2, 3));
  });
  test('Polygon.fromPoints', () {
    var a = Polygon.fromPoints(points: [
      [Point(coordinates: Position(1, 2, 3))]
    ]);
    expect(a.coordinates.first.first, Position(1, 2, 3));
  });
  test('MultiPolygon.fromPolygons', () {
    var a = MultiPolygon.fromPolygons(polygons: [
      Polygon.fromPoints(points: [
        [Point(coordinates: Position(1, 2, 3))]
      ])
    ]);
    expect(a.coordinates.first.first.first, Position(1, 2, 3));
  });
}
