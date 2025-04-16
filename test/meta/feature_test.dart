import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  group('Feature Extensions', () {
    test('copyWith method creates a correct copy with modified properties', () {
      // Create an original feature
      final Feature<Point> original = Feature<Point>(
        id: 'original-id',
        geometry: Point(coordinates: Position(0, 0)),
        properties: {'name': 'Original feature'},
      );

      // Create a modified copy using copyWith
      final Feature<Point> modified = original.copyWith<Point>(
        id: 'modified-id',
        geometry: Point(coordinates: Position(10, 20)),
        properties: {'name': 'Modified feature', 'tag': 'test'},
      );

      // Verify original is unchanged
      expect(original.id, equals('original-id'));
      expect(original.geometry!.coordinates.lng, equals(0));
      expect(original.geometry!.coordinates.lat, equals(0));
      expect(original.properties!['name'], equals('Original feature'));
      expect(original.properties!.containsKey('tag'), isFalse);

      // Verify modified has correct values
      expect(modified.id, equals('modified-id'));
      expect(modified.geometry!.coordinates.lng, equals(10));
      expect(modified.geometry!.coordinates.lat, equals(20));
      expect(modified.properties!['name'], equals('Modified feature'));
      expect(modified.properties!['tag'], equals('test'));
    });

    test('copyWith method works with partial updates', () {
      // Create an original feature
      final Feature<Point> original = Feature<Point>(
        id: 'original-id',
        geometry: Point(coordinates: Position(0, 0)),
        properties: {'name': 'Original feature'},
      );

      // Update only the id
      final Feature<Point> idOnly = original.copyWith<Point>(
        id: 'new-id',
      );
      expect(idOnly.id, equals('new-id'));
      expect(idOnly.geometry, equals(original.geometry));
      expect(idOnly.properties, equals(original.properties));

      // Update only the geometry
      final Feature<Point> geometryOnly = original.copyWith<Point>(
        geometry: Point(coordinates: Position(5, 5)),
      );
      expect(geometryOnly.id, equals(original.id));
      expect(geometryOnly.geometry!.coordinates.lng, equals(5));
      expect(geometryOnly.geometry!.coordinates.lat, equals(5));
      expect(geometryOnly.properties, equals(original.properties));

      // Update only properties
      final Feature<Point> propertiesOnly = original.copyWith<Point>(
        properties: {'updated': true},
      );
      expect(propertiesOnly.id, equals(original.id));
      expect(propertiesOnly.geometry, equals(original.geometry));
      expect(propertiesOnly.properties!['updated'], isTrue);
      expect(propertiesOnly.properties!.containsKey('name'), isFalse);
    });

    test('copyWith handles bbox correctly', () {
      // Create an original feature with bbox
      final Feature<Point> original = Feature<Point>(
        id: 'original-id',
        geometry: Point(coordinates: Position(0, 0)),
        properties: {'name': 'Original feature'},
        bbox: BBox(0, 0, 10, 10),
      );

      // Update only the bbox
      final Feature<Point> bboxOnly = original.copyWith<Point>(
        bbox: BBox(5, 5, 15, 15),
      );
      
      expect(bboxOnly.id, equals(original.id));
      expect(bboxOnly.geometry, equals(original.geometry));
      expect(bboxOnly.properties, equals(original.properties));
      expect(bboxOnly.bbox!.lng1, equals(5));
      expect(bboxOnly.bbox!.lat1, equals(5));
      expect(bboxOnly.bbox!.lng2, equals(15));
      expect(bboxOnly.bbox!.lat2, equals(15));
    });
    
    test('copyWith handles changing geometry type', () {
      // Create a Point feature
      final Feature<Point> pointFeature = Feature<Point>(
        id: 'point-id',
        geometry: Point(coordinates: Position(0, 0)),
        properties: {'type': 'point'},
      );
      
      // Convert to a LineString feature
      final Feature<LineString> lineFeature = pointFeature.copyWith<LineString>(
        geometry: LineString(coordinates: [
          Position(0, 0),
          Position(1, 1),
        ]),
        properties: {'type': 'line'},
      );
      
      expect(lineFeature.id, equals('point-id'));
      expect(lineFeature.geometry!.type, equals(GeoJSONObjectType.lineString));
      expect(lineFeature.geometry!.coordinates.length, equals(2));
      expect(lineFeature.properties!['type'], equals('line'));
    });
    
    test('copyWith handles type checking', () {
      // Create a Point feature
      final Feature<Point> pointFeature = Feature<Point>(
        geometry: Point(coordinates: Position(0, 0)),
      );
      
      // It's not possible to directly create this error since the Dart type system
      // prevents it. However, we can verify that the method correctly handles 
      // the type checks for valid cases.
      
      // This should work fine - creating a Point feature from another Point feature
      final Feature<Point> stillPointFeature = pointFeature.copyWith<Point>();
      expect(stillPointFeature.geometry, isNotNull);
      expect(stillPointFeature.geometry, isA<Point>());
      
      // This should also work - explicitly changing to a new geometry type
      final Feature<LineString> lineFeature = pointFeature.copyWith<LineString>(
        geometry: LineString(coordinates: [Position(0, 0), Position(1, 1)]),
      );
      expect(lineFeature.geometry, isNotNull);
      expect(lineFeature.geometry, isA<LineString>());
    });
    
    test('copyWith throws error when target type is incompatible with original geometry', () {
      // Create a Point feature
      final Feature<Point> pointFeature = Feature<Point>(
        geometry: Point(coordinates: Position(0, 0)),
      );
      
      // Try to create a LineString feature without providing a new geometry
      expect(() => pointFeature.copyWith<LineString>(), throwsArgumentError);
    });
  });
}
