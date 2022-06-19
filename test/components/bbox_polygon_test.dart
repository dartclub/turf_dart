import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/bbox_polygon.dart';
import 'package:turf/src/bbox.dart';

main() {
  test(
    "bbox-polygon",
    () {
      var poly = bboxPolygon(Bbox(0, 0, 10, 10));
      expect(poly.geometry is Polygon, true);
    },
  );

  test(
    "bbox-polygon -- valid geojson",
    () {
      var poly = bboxPolygon(Bbox(0, 0, 10, 10));
      var coordinates = poly.geometry!.coordinates;

      expect(coordinates[0].length == 5, true);
      expect(coordinates[0][0][0] == coordinates[0][coordinates.length - 1][0],
          true);
      expect(coordinates[0][0][1] == coordinates[0][coordinates.length - 1][1],
          true);
    },
  );

  test(
    "bbox-polygon -- Error handling",
    () {
      expect(() => bboxPolygon(Bbox(-110, 70, 5000, 50, 60, 3000)),
          throwsA(isA<Exception>()));
    },
  );

  test(
    "bbox-polygon -- Translate BBox (Issue #1179)",
    () {
      var id = 123;
      var properties = {"foo": "bar"};
      var bbox = Bbox(0, 0, 10, 10);
      var poly = bboxPolygon(bbox, properties: properties, id: id);

      expect(poly.properties, equals(properties));
      expect(poly.bbox, equals(bbox));
      expect(poly.id, equals(id));
    },
  );

  test(
    "bbox-polygon -- assert bbox",
    () {
      var bbox = Bbox(0, 0, 10, 10);
      var poly = bboxPolygon(bbox);
      expect(poly.bbox, equals(bbox));
    },
  );
}
