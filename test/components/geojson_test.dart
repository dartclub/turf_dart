import 'dart:convert';
import 'dart:io';
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

      expect(pos1, pos1.clone());
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

  test('GeoJSONObject and GeometryObject.deserialize enum test', () {
    final geoJSON =
        GeometryCollection(geometries: [Point(coordinates: Position(1, 1, 1))]);

    final collection = GeometryObject.deserialize(geoJSON.toJson());
    expect(collection, isA<GeometryCollection>());
    expect(collection.type, GeoJSONObjectType.geometryCollection);
    expect((collection as GeometryCollection).geometries.first.type,
        GeoJSONObjectType.point);

    final geoJSON2 = {
      "type": GeoJSONObjectType.geometryCollection,
      "geometries": [
        {
          "type": GeoJSONObjectType.point,
          "coordinates": [1, 1, 1]
        }
      ]
    };

    final collection2 = GeometryObject.deserialize(geoJSON2);

    expect(collection2, isA<GeometryCollection>());
    expect(collection2.type, GeoJSONObjectType.geometryCollection);
    expect((collection2 as GeometryCollection).geometries.first.type,
        GeoJSONObjectType.point);

    var collection3 = GeoJSONObject.fromJson(geoJSON2);

    expect(collection3, isA<GeometryCollection>());
    expect(collection3.type, GeoJSONObjectType.geometryCollection);
    expect((collection3 as GeometryCollection).geometries.first.type,
        GeoJSONObjectType.point);

    var geoJSON3 = {
      "type": GeoJSONObjectType.geometryCollection,
      "geometries": [
        {"type": GeoJSONObjectType.feature, "id": 1}
      ]
    };
    expect(() => GeometryType.deserialize(geoJSON3), throwsA(isA<Exception>()));
  });

  test(
    '.clone()',
    () {
      final coll = FeatureCollection<GeometryCollection>(
        bbox: BBox(100, 0, 101, 1),
        features: [
          Feature(
              bbox: BBox(100, 0, 101, 1),
              geometry: GeometryCollection(
                bbox: BBox(100, 0, 101, 1),
                geometries: [
                  LineString(
                    bbox: BBox(100, 0, 101, 1),
                    coordinates: [Position(100, 0), Position(101, 1)],
                  ),
                  MultiLineString.fromLineStrings(
                    bbox: BBox(100, 0, 101, 1),
                    lineStrings: [
                      LineString(
                        bbox: BBox(100, 0, 101, 1),
                        coordinates: [Position(100, 0), Position(101, 1)],
                      ),
                      LineString(
                        bbox: BBox(100, 0, 101, 1),
                        coordinates: [Position(100, 1), Position(101, 0)],
                      ),
                    ],
                  ),
                  MultiPoint.fromPoints(
                    bbox: BBox(100, 0, 101, 1),
                    points: [
                      Point(coordinates: Position(100, 0)),
                      Point(coordinates: Position(100.5, 0.5)),
                      Point(coordinates: Position(101, 1)),
                    ],
                  ),
                  Polygon(
                    bbox: BBox(100, 0, 101, 1),
                    coordinates: [
                      [
                        Position(100, 0),
                        Position(100, 1),
                        Position(101, 0),
                      ]
                    ],
                  ),
                  MultiPolygon.fromPolygons(
                    bbox: BBox(100, 0, 101, 1),
                    polygons: [
                      Polygon(coordinates: [
                        [
                          Position(100, 0),
                          Position(100, 1),
                          Position(101, 0),
                        ]
                      ]),
                      Polygon(coordinates: [
                        [
                          Position(100, 0),
                          Position(100, 1),
                          Position(101, 0),
                        ]
                      ])
                    ],
                  ),
                ],
              ),
              id: 1,
              properties: {"key": "val"}),
        ],
      );
      final cloned = coll.clone();
      final feat = cloned.features.first;
      final bbox = BBox(100, 0, 101, 1);
      expect(cloned.bbox, bbox);
      expect(feat.id, 1);
      expect(feat.bbox, bbox);
      expect(feat.properties!.keys.first, "key");
      expect(feat.properties!.values.first, "val");
      expect(feat.geometry!, isA<GeometryCollection>());
      final geomColl = feat.geometry!;
      expect(geomColl.geometries.length,
          coll.features.first.geometry!.geometries.length);
      for (var geom in geomColl.geometries) {
        expect(geom.bbox, isNotNull);
        expect(geom.coordinates, isNotEmpty);

        _expandRecursively(List inner) {
          if (inner is List<Position>) {
            return inner;
          } else {
            return inner
                .expand((el) => el is List ? _expandRecursively(el) : el);
          }
        }

        var expanded = _expandRecursively(geom.coordinates);
        expect(
          expanded.first,
          Position(100, 0),
        );
      }
      // TODO refine tests
    },
  );

  final points = [
    Point(coordinates: Position(1, 2, 3)),
    Point(coordinates: Position(2, 1, 3)),
    Point(coordinates: Position(3, 2, 1)),
  ];
  test('MultiPoint.fromPoints', () {
    var a = MultiPoint.fromPoints(points: points);
    expect(a.coordinates.first, Position(1, 2, 3));
    expect(() => MultiPoint.fromPoints(points: []),
        throwsA(isA<AssertionError>()));
  });
  test('LineString.fromPoints', () {
    var a = LineString.fromPoints(points: points);
    expect(a.coordinates.first, Position(1, 2, 3));
    expect(() => LineString.fromPoints(points: []),
        throwsA(isA<AssertionError>()));
  });
  test('MultiLineString.fromLineStrings', () {
    var a = MultiLineString.fromLineStrings(lineStrings: [
      LineString.fromPoints(points: points),
      LineString.fromPoints(points: points)
    ]);
    expect(a.coordinates.first.first, Position(1, 2, 3));
    expect(() => MultiLineString.fromLineStrings(lineStrings: []),
        throwsA(isA<AssertionError>()));
  });
  test('Polygon.fromPoints', () {
    var a = Polygon.fromPoints(points: [points]);
    expect(a.coordinates.first.first, Position(1, 2, 3));
    expect(
        () => Polygon.fromPoints(points: []), throwsA(isA<AssertionError>()));
  });
  test('MultiPolygon.fromPolygons', () {
    var a = MultiPolygon.fromPolygons(polygons: [
      Polygon.fromPoints(points: [points]),
      Polygon.fromPoints(points: [points])
    ]);
    expect(a.coordinates.first.first.first, Position(1, 2, 3));
    expect(() => MultiPolygon.fromPolygons(polygons: []),
        throwsA(isA<AssertionError>()));
  });

// examples
// copied from RFC 7946 https://datatracker.ietf.org/doc/html/rfc7946
// copied from Wikipedia https://en.wikipedia.org/wiki/GeoJSON#Geometries
  group('Example file', () {
    var dir = Directory('./test/examples');
    for (var file in dir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.geojson')) {
        test(file.path, () {
          var source = (file).readAsStringSync();
          var json = jsonDecode(source);
          GeoJSONObject.fromJson(json);
        });
      }
    }
  });
}
