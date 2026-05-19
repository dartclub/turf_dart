import 'package:turf/to_mercator.dart';
import 'package:turf/to_wgs84.dart';

void main() {
  print('=== Web Mercator Transformations Examples ===\n');

  // Point conversion example
  final point = Feature(
    geometry: Point(coordinates: Position(-74.006, 40.7128, 10.0)),
  ); // New York City
  print('WGS84 Point: ${point.geometry!.coordinates}');

  final mercatorPoint = geoToMercator(point) as Feature<Point>;
  print('Mercator Point: ${mercatorPoint.geometry!.coordinates}');

  final backToWgs84 = geoToWgs84(mercatorPoint) as Feature<Point>;
  print('Back to WGS84: ${backToWgs84.geometry!.coordinates}\n');

  // LineString example
  final lineString = Feature(
    geometry: LineString(coordinates: [
      Position(0, 0),
      Position(10, 10),
      Position(20, 0),
    ]),
  );
  print('WGS84 LineString: ${lineString.geometry!.coordinates}');

  final mercatorLine = geoToMercator(lineString) as Feature<LineString>;
  print('Mercator LineString: ${mercatorLine.geometry!.coordinates}');

  final wgs84Line = geoToWgs84(mercatorLine) as Feature<LineString>;
  print('Back to WGS84 LineString: ${wgs84Line.geometry!.coordinates}\n');

  // Feature with properties example
  final feature = Feature<Point>(
    geometry: Point(coordinates: Position(139.6917, 35.6895, 5.0)), // Tokyo
    properties: {'name': 'Tokyo', 'country': 'Japan'},
  );
  print('WGS84 Feature: $feature');

  // mutate: false — original unchanged
  final mercatorFeature =
      geoToMercator(feature, mutate: false) as Feature<Point>;
  print('Mercator Feature: $mercatorFeature');
  print(
      'Original feature unchanged: ${feature.geometry!.coordinates != mercatorFeature.geometry!.coordinates}');

  // mutate: true — better performance
  final clonedFeature = feature.clone();
  final mutatedFeature =
      geoToMercator(clonedFeature, mutate: true) as Feature<Point>;
  print('Mutated Feature: $mutatedFeature');
  print(
      'Original feature modified (when mutate=true): ${clonedFeature.geometry!.coordinates == mutatedFeature.geometry!.coordinates}\n');

  // FeatureCollection example
  final featureCollection = FeatureCollection(features: [
    Feature<Point>(
      geometry: Point(coordinates: Position(2.3522, 48.8566)), // Paris
      properties: {'name': 'Paris'},
    ),
    Feature<Point>(
      geometry: Point(coordinates: Position(37.6173, 55.7558)), // Moscow
      properties: {'name': 'Moscow'},
    ),
  ]);
  print('WGS84 FeatureCollection: $featureCollection');

  final mercatorFc = geoToMercator(featureCollection) as FeatureCollection;
  print('Mercator FeatureCollection: $mercatorFc');

  final wgs84Fc = geoToWgs84(mercatorFc) as FeatureCollection;
  print('Back to WGS84 FeatureCollection: $wgs84Fc\n');

  print('=== Usage Tips ===');
  print(
      '1. Use geoToMercator() to convert any GeoJSON object from WGS84 to Web Mercator');
  print(
      '2. Use geoToWgs84() to convert any GeoJSON object from Web Mercator back to WGS84');
  print(
      '3. Set mutate=true for better performance when you don\'t need to preserve the original');
  print('4. Round-trip conversions maintain high accuracy');
}
