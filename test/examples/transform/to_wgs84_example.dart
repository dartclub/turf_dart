import 'package:turf/to_mercator.dart';
import 'package:turf/to_wgs84.dart';

void main() {
  print('=== Web Mercator to WGS84 Transformations Examples ===\n');

  // Point conversion example
  final mercatorPoint = Feature(
    geometry: Point(coordinates: Position(-8237642.31, 4970241.32, 10.0)),
  ); // New York City in Mercator
  print('Mercator Point: ${mercatorPoint.geometry!.coordinates}');

  final wgs84Point = geoToWgs84(mercatorPoint) as Feature<Point>;
  print('WGS84 Point: ${wgs84Point.geometry!.coordinates}');

  final backToMercator = geoToMercator(wgs84Point) as Feature<Point>;
  print('Back to Mercator: ${backToMercator.geometry!.coordinates}\n');

  // LineString example
  final mercatorLine = Feature(
    geometry: LineString(coordinates: [
      Position(0, 0),
      Position(1113195, 1118890),
      Position(2226390, 0),
    ]),
  );
  print('Mercator LineString: ${mercatorLine.geometry!.coordinates}');

  final wgs84Line = geoToWgs84(mercatorLine) as Feature<LineString>;
  print('WGS84 LineString: ${wgs84Line.geometry!.coordinates}');

  final mercatorLineAgain = geoToMercator(wgs84Line) as Feature<LineString>;
  print(
      'Back to Mercator LineString: ${mercatorLineAgain.geometry!.coordinates}\n');

  // Feature with properties example
  final mercatorFeature = Feature<Point>(
    geometry:
        Point(coordinates: Position(15550408.91, 4257980.73, 5.0)), // Tokyo
    properties: {'name': 'Tokyo', 'country': 'Japan'},
  );
  print('Mercator Feature: $mercatorFeature');

  // mutate: false — original unchanged
  final wgs84Feature =
      geoToWgs84(mercatorFeature, mutate: false) as Feature<Point>;
  print('WGS84 Feature: $wgs84Feature');
  print(
      'Original feature unchanged: ${mercatorFeature.geometry!.coordinates != wgs84Feature.geometry!.coordinates}');

  // mutate: true — better performance
  final clonedFeature = mercatorFeature.clone();
  final mutatedFeature =
      geoToWgs84(clonedFeature, mutate: true) as Feature<Point>;
  print('Mutated Feature: $mutatedFeature');
  print(
      'Original feature modified (when mutate=true): ${clonedFeature.geometry!.coordinates == mutatedFeature.geometry!.coordinates}\n');

  // FeatureCollection example
  final mercatorFc = FeatureCollection(features: [
    Feature<Point>(
      geometry: Point(coordinates: Position(261865.42, 6250566.48)), // Paris
      properties: {'name': 'Paris'},
    ),
    Feature<Point>(
      geometry: Point(coordinates: Position(4187399.59, 7509720.48)), // Moscow
      properties: {'name': 'Moscow'},
    ),
  ]);
  print('Mercator FeatureCollection: $mercatorFc');

  final wgs84Fc = geoToWgs84(mercatorFc) as FeatureCollection;
  print('WGS84 FeatureCollection: $wgs84Fc');

  final mercatorFcAgain = geoToMercator(wgs84Fc) as FeatureCollection;
  print('Back to Mercator FeatureCollection: $mercatorFcAgain\n');

  print('=== Round-trip Conversion Accuracy ===');
  final original = Feature(
    geometry: Point(coordinates: Position(10.0, 20.0, 30.0)),
  );
  print('Original WGS84: ${original.geometry!.coordinates}');

  final converted = geoToMercator(original) as Feature<Point>;
  print('Converted to Mercator: ${converted.geometry!.coordinates}');

  final roundTrip = geoToWgs84(converted) as Feature<Point>;
  print('Converted back to WGS84: ${roundTrip.geometry!.coordinates}');

  final lonDiff = (10.0 - roundTrip.geometry!.coordinates.lng.toDouble()).abs();
  final latDiff = (20.0 - roundTrip.geometry!.coordinates.lat.toDouble()).abs();
  print('Longitude difference: $lonDiff°');
  print('Latitude difference: $latDiff°\n');

  print('=== Usage Tips ===');
  print(
      '1. Use geoToWgs84() to convert any GeoJSON object from Web Mercator to WGS84');
  print(
      '2. Use geoToMercator() to convert any GeoJSON object from WGS84 to Web Mercator');
  print(
      '3. Set mutate=true for better performance when you don\'t need to preserve the original');
  print(
      '4. Round-trip conversions maintain high accuracy, but tiny numeric differences may occur');
}
