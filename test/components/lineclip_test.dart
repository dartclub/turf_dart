import 'package:turf/lineclip.dart';
import 'package:test/test.dart';

void main() {
  group('Clipping Tests', () {
    test('Line Clipping: Simple case inside bbox', () {
      // Define a bounding box
      BBox bbox = BBox.named(lat1: 0.0, lng1: 0.0, lat2: 10.0, lng2: 10.0);

      // Define a simple polyline (inside bbox)
      List<Position> points = [
        Position.named(lat: 1.0, lng: 1.0),
        Position.named(lat: 2.0, lng: 2.0),
        Position.named(lat: 3.0, lng: 3.0),
      ];

      // Call the line clipping function
      List<List<Position>> result = lineclip(points, bbox);

      // Expect the result to be the same as the input (since it's inside the bbox)
      expect(result, equals([points]));
    });

    test('Line Clipping: Simple case outside bbox (left)', () {
      // Define a bounding box
      BBox bbox = BBox.named(lat1: 0.0, lng1: 0.0, lat2: 10.0, lng2: 10.0);

      // Define a polyline that extends outside the bbox (left)
      List<Position> points = [
        Position.named(lat: -1.0, lng: 5.0),
        Position.named(lat: 1.0, lng: 5.0),
      ];

      // Call the line clipping function
      List<List<Position>> result = lineclip(points, bbox);

      // We expect one segment with a clipped point at the left edge
      expect(result.length, equals(1));
      expect(result[0].length, equals(2));
      expect(result[0][0].lat, equals(0.0)); // The intersection should clip at lat=0.0
    });

    test('Polygon Clipping: Simple square inside bbox', () {
      // Define a bounding box
      BBox bbox = BBox.named(lat1: 0.0, lng1: 0.0, lat2: 10.0, lng2: 10.0);

      // Define a square polygon inside the bbox
      List<Position> points = [
        Position.named(lat: 1.0, lng: 1.0),
        Position.named(lat: 1.0, lng: 3.0),
        Position.named(lat: 3.0, lng: 3.0),
        Position.named(lat: 3.0, lng: 1.0),
      ];

      // Call the polygon clipping function
      List<Position> result = polygonclip(points, bbox);

      // The result should be the same as the input, since it's inside the bbox
      expect(result, equals(points));
    });

    test('Polygon Clipping: Polygon partially outside bbox', () {
      // Define a bounding box
      BBox bbox = BBox.named(lat1: 0.0, lng1: 0.0, lat2: 5.0, lng2: 5.0);

      // Define a polygon that partially crosses outside the bbox
      List<Position> points = [
        Position.named(lat: -1.0, lng: 1.0), // outside bbox
        Position.named(lat: 1.0, lng: 1.0),  // inside bbox
        Position.named(lat: 1.0, lng: 3.0),  // inside bbox
        Position.named(lat: -1.0, lng: 3.0), // outside bbox
      ];

      // Call the polygon clipping function
      List<Position> result = polygonclip(points, bbox);

      // We expect the polygon to be clipped to the bounding box
      expect(result.length, greaterThan(0));  // Expect the clipped polygon to have some vertices
    });

    test('Polygon Clipping: Polygon fully outside bbox', () {
      // Define a bounding box
      BBox bbox = BBox.named(lat1: 0.0, lng1: 0.0, lat2: 5.0, lng2: 5.0);

      // Define a polygon that is completely outside the bbox
      List<Position> points = [
        Position.named(lat: -1.0, lng: -1.0),
        Position.named(lat: -1.0, lng: 6.0),
        Position.named(lat: 6.0, lng: 6.0),
        Position.named(lat: 6.0, lng: -1.0),
      ];

      // Call the polygon clipping function
      List<Position> result = polygonclip(points, bbox);

      // The result should be an empty list, as the polygon is completely outside
      expect(result, equals([]));
    });
  });
}
