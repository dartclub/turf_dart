import 'package:test/test.dart';
import 'package:turf/helpers.dart';

void main() {
  group('Coordinate System Conversions', () {
    test('convertCoordinates should convert between systems', () {
      final wgs84Point = Position.of([10.0, 20.0, 100.0]); // longitude, latitude, altitude
      
      // WGS84 to Mercator
      final mercatorPoint = convertCoordinates(
        wgs84Point, 
        CoordinateSystem.wgs84, 
        CoordinateSystem.mercator
      );
      
      // Mercator to WGS84 (should get back close to the original)
      final reconvertedPoint = convertCoordinates(
        mercatorPoint, 
        CoordinateSystem.mercator, 
        CoordinateSystem.wgs84
      );
      
      // Verify values are close to the originals
      expect(reconvertedPoint[0]?.toDouble() ?? 0.0, closeTo(wgs84Point[0]?.toDouble() ?? 0.0, 0.001)); // longitude
      expect(reconvertedPoint[1]?.toDouble() ?? 0.0, closeTo(wgs84Point[1]?.toDouble() ?? 0.0, 0.001)); // latitude
      expect(reconvertedPoint[2], equals(wgs84Point[2])); // altitude should be preserved
    });
    
    test('toMercator should preserve altitude', () {
      final wgs84Point = Position.of([10.0, 20.0, 100.0]); // longitude, latitude, altitude
      final mercatorPoint = toMercator(wgs84Point);
      
      // Check that altitude is preserved
      expect(mercatorPoint.length, equals(3));
      expect(mercatorPoint[2], equals(100.0));
    });
    
    test('toWGS84 should preserve altitude', () {
      final mercatorPoint = Position.of([1113194.9079327357, 2273030.92688923, 100.0]); // x, y, altitude
      final wgs84Point = toWGS84(mercatorPoint);
      
      // Check that altitude is preserved
      expect(wgs84Point.length, equals(3));
      expect(wgs84Point[2], equals(100.0));
    });
  });
}
