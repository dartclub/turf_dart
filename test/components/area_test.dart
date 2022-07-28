import 'package:test/test.dart';
import 'package:turf/turf.dart';

main() {
  group('area', () {
    final position1 = Position(0, 0);
    final position2 = Position(0, 1);
    final positions = [position1, position2];
    final point = Point(coordinates: position1);
    final multiPoint = MultiPoint(coordinates: positions);
    final lineString = LineString(coordinates: positions);
    final multiLineString = LineString(coordinates: positions);
    List<GeometryType> zeroAreaGeometries = [
      point,
      multiPoint,
      lineString,
      multiLineString
    ];

    final geometryCollection =
        GeometryCollection(geometries: zeroAreaGeometries);

    Polygon polygon = Polygon(coordinates: [
      [
        Position(125, -15),
        Position(113, -22),
        Position(117, -37),
        Position(130, -33),
        Position(148, -39),
        Position(154, -27),
        Position(144, -15),
        Position(125, -15)
      ]
    ]);

    test('test area of polygon', () {
      var areaResult = area(polygon);
      expect(areaResult, isNot(equals(null)));
      final roundedResult = round(areaResult!);
      expect(roundedResult, equals(7748891609977));
    });

    test(
        'test area of polygon equals to the area of a feature and a feature collection that includes it',
        () {
      var polygonAreaResult = round(area(polygon)!);
      var featureAreaResult = round(area(Feature(geometry: polygon))!);
      var featureCollectionAreaResult = round(
          area(FeatureCollection(features: [Feature(geometry: polygon)]))!);
      expect(polygonAreaResult, equals(featureAreaResult));
      expect(featureCollectionAreaResult, equals(featureAreaResult));
    });

    test('test area of polygon feature', () {
      var areaResult = area(polygon);
      expect(areaResult, isNot(equals(null)));
      final roundedResult = round(areaResult!);
      expect(roundedResult, equals(7748891609977));
    });

    test('area of point, multiPoint, lineString and multiLineString are 0', () {
      expect(area(point), equals(0));
      expect(area(multiPoint), equals(0));
      expect(area(lineString), equals(0));
      expect(area(multiLineString), equals(0));
    });

    test(
        'area of geometry collection of (point, multiPoint, lineString and multiLineString) is 0',
        () {
      expect(area(geometryCollection), equals(0));
    });
  });
}
