import 'dart:convert';
import 'dart:io';
import 'package:turf/turf.dart';

void main() async {
  // Create a single visualization file showing all inputs and their corresponding points
  await generateVisualization();
  
  print('Visualization file generated successfully!');
}

Future<void> generateVisualization() async {
  try {
    final files = [
      'polygon_feature.geojson',
      'polygon.geojson',
      'linestring.geojson',
      'multipolygon.geojson',
      'point.geojson',
      'featurecollection.geojson'
    ];
    
    // List to store all features
    final allFeatures = <Feature>[];
    
    // Process each output file only (since they now contain both input and result)
    for (final filename in files) {
      final outputPath = 'test/examples/point_on_feature/out/$filename';
      
      print('Processing $filename for visualization');
      
      // Read the output file
      final outputFile = File(outputPath);
      
      if (!outputFile.existsSync()) {
        print('  Missing output file for $filename, skipping');
        continue;
      }
      
      final outputJson = jsonDecode(await outputFile.readAsString());
      
      // The output files are already FeatureCollections with styled features
      if (outputJson['type'] == 'FeatureCollection' && outputJson['features'] is List) {
        final outFeatures = outputJson['features'] as List;
        
        // Add custom markers based on the geometry type for the result point
        for (final feature in outFeatures) {
          if (feature['properties'] != null && 
              feature['properties']['name'] == 'Point on Feature Result') {
            
            // Update description based on geometry type
            if (filename == 'point.geojson') {
              feature['properties']['description'] = 'Point on a Point: Returns the original point unchanged';
              feature['properties']['marker-symbol'] = 'star';
            } else if (filename == 'linestring.geojson') {
              feature['properties']['description'] = 'Point on a LineString: Returns the midpoint of the first segment';
              feature['properties']['marker-symbol'] = 'circle';
            } else if (filename.contains('polygon') && !filename.contains('multi')) {
              feature['properties']['description'] = 'Point on a Polygon: Returns a point inside the polygon (prefers centroid)';
              feature['properties']['marker-symbol'] = 'triangle';
            } else if (filename == 'multipolygon.geojson') {
              feature['properties']['description'] = 'Point on a MultiPolygon: Returns a point from the first polygon';
              feature['properties']['marker-symbol'] = 'square';
            } else if (filename == 'featurecollection.geojson') {
              feature['properties']['description'] = 'Point on a FeatureCollection: Returns a point on the largest feature';
              feature['properties']['marker-symbol'] = 'circle-stroked';
            }
            
            feature['properties']['name'] = 'Result: $filename';
          }
          
          // Add the feature to our collection
          try {
            final parsedFeature = Feature.fromJson(feature);
            allFeatures.add(parsedFeature);
          } catch (e) {
            print('  Error parsing feature: $e');
          }
        }
      }
    }
    
    // Create the feature collection
    final featureCollection = FeatureCollection(features: allFeatures);
    
    // Save the visualization file with pretty formatting
    final visualizationFile = File('test/examples/point_on_feature/visualization.geojson');
    await visualizationFile.writeAsString(JsonEncoder.withIndent('  ').convert(featureCollection.toJson()));
    
    print('Saved visualization to ${visualizationFile.path}');
  } catch (e) {
    print('Error generating visualization: $e');
  }
}

// Helper function to set style properties for features
void setFeatureStyle(Feature feature, String color, int width, double opacity) {
  feature.properties = feature.properties ?? {};
  
  // Different styling based on geometry type
  if (feature.geometry is Polygon || feature.geometry is MultiPolygon) {
    feature.properties!['stroke'] = color;
    feature.properties!['stroke-width'] = width;
    feature.properties!['stroke-opacity'] = 1;
    feature.properties!['fill'] = color;
    feature.properties!['fill-opacity'] = opacity;
  } else if (feature.geometry is LineString || feature.geometry is MultiLineString) {
    feature.properties!['stroke'] = color;
    feature.properties!['stroke-width'] = width;
    feature.properties!['stroke-opacity'] = 1;
  } else if (feature.geometry is Point || feature.geometry is MultiPoint) {
    feature.properties!['marker-color'] = color;
    feature.properties!['marker-size'] = 'small';
  }
}

// Helper function to parse geometries from JSON
GeometryObject? parseGeometry(Map<String, dynamic> json) {
  final type = json['type'];
  
  switch (type) {
    case 'Point':
      return Point.fromJson(json);
    case 'LineString':
      return LineString.fromJson(json);
    case 'Polygon':
      return Polygon.fromJson(json);
    case 'MultiPoint':
      return MultiPoint.fromJson(json);
    case 'MultiLineString':
      return MultiLineString.fromJson(json);
    case 'MultiPolygon':
      return MultiPolygon.fromJson(json);
    case 'GeometryCollection':
      return GeometryCollection.fromJson(json);
    default:
      return null;
  }
}
