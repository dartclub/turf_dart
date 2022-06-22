import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';
import 'package:turf/src/invariant.dart';

/// Converts [LineString]s & [MultiLineString](s) to [Polygon](s).
/// Takes an optional bool autoComplete=true that auto complete [Linestring]s (matches first & last coordinates)
/// Takes an optional orderCoords=true that sorts [Linestring]s to place outer ring at the first position of the coordinates
/// Takes an optional mutate=false that mutates the original [Linestring] using autoComplete (matches first & last coordinates)
/// Returns [Feature<Polygon>] or [Feature<MultiPolygon>] converted to Polygons.
/// example:
/// ```dart
/// var line = LineString(coordinates: [
/// Position.of([125, -30]),
/// Position.of([145, -30]),
/// Position.of([145, -20]),
/// Position.of([125, -20]),
/// Position.of([125, -30])]);
/// var polygon = lineToPolygon(line);
/// //addToMap
/// var addToMap = [polygon];
/// ```
Feature lineToPolygon(
  GeoJSONObject lines, {
  Map<String, dynamic>? properties,
  bool autoComplete = true,
  bool orderCoords = true,
  bool mutate = false,
}) {
  Exception exc = Exception(
      """allowed types are Feature<LineString||MultiLineString>, LineString,
         MultiLineString, FeatureCollection<LineString || MultiLineString>""");
  if (lines is FeatureCollection) {
    featureEach(
      lines,
      (currentFeature, index) {
        if (currentFeature.geometry is! LineString &&
            currentFeature.geometry is! MultiLineString) {
          throw exc;
        }
      },
    );
    List<List<Position>> list = [];
    geomEach(
      lines,
      (
        GeometryType? currentGeometry,
        int? featureIndex,
        Map<String, dynamic>? featureProperties,
        BBox? featureBBox,
        dynamic featureId,
      ) {
        if (currentGeometry is LineString) {
          list.add(currentGeometry.coordinates);
        } else {
          list = [...list, ...currentGeometry?.coordinates];
        }
      },
    );

    lines = FeatureCollection<MultiLineString>(features: [])
      ..features.add(Feature(geometry: MultiLineString(coordinates: list)));
  } else if (lines is Feature) {
    if (lines.geometry is LineString) {
      lines = Feature<LineString>(
        geometry: lines.geometry as LineString,
        properties: lines.properties,
        id: lines.id,
      );
    } else if (lines.geometry is MultiLineString) {
      lines = Feature<MultiLineString>(
        geometry: lines.geometry as MultiLineString,
        properties: lines.properties,
        id: lines.id,
      );
    } else {
      throw exc;
    }
  } else if (lines is LineString) {
    lines = Feature<LineString>(geometry: lines);
  } else if (lines is MultiLineString) {
    lines = Feature<MultiLineString>(geometry: lines);
  } else {
    throw exc;
  }
  if (!mutate) {
    lines = lines.clone();
  }

  if (lines is FeatureCollection) {
    List<List<List<Position>>> coords = [];
    featureEach(
      lines,
      ((line, featureIndex) => coords.add(getCoords(lineStringToPolygon(
              line, autoComplete, orderCoords, properties: {}))
          as List<List<Position>>)),
    );
    return Feature(
        geometry: MultiPolygon(coordinates: coords), properties: properties);
  } else {
    return lineStringToPolygon(lines, autoComplete, orderCoords,
        properties: properties);
  }
}

/// Converts LineString to Polygon
/// Takes a optional bool autoComplete=true that auto completes linestrings
/// Takes an optional orderCoords=true that sorts linestrings to place outer
/// ring at the first position of the coordinates.
Feature<Polygon> lineStringToPolygon(
    GeoJSONObject line, bool autoComplete, bool orderCoords,
    {Map<String, dynamic>? properties}) {
  properties = properties ?? (line is Feature ? line.properties ?? {} : {});
  var geom = line is LineString ? line : (line as Feature).geometry;
  List<dynamic> coords = (geom is LineString || geom is MultiLineString)
      ? (geom is LineString)
          ? geom.coordinates
          : (geom as MultiLineString).coordinates
      : ((geom as Feature).geometry as GeometryType).coordinates;

  if (coords.isEmpty) throw Exception("line must contain coordinates");

  if (geom is LineString) {
    if (autoComplete) {
      coords = _autoCompleteCoords(coords as List<Position>);
    }
    return Feature(
        geometry: Polygon(coordinates: [coords as List<Position>]),
        properties: properties);
  } else if (geom is MultiLineString) {
    List<List<Position>> multiCoords = [];
    num largestArea = 0;

    (coords as List<List<Position>>).forEach((coord) {
      if (autoComplete) {
        coord = _autoCompleteCoords(coord);
      }

      // Largest LineString to be placed in the first position of the coordinates array
      if (orderCoords) {
        var area = _calculateArea(bbox(LineString(coordinates: coord)));
        if (area > largestArea) {
          multiCoords.insert(0, coord);
          largestArea = area;
        } else {
          multiCoords.add(coord);
        }
      } else {
        multiCoords.add(coord);
      }
    });
    return Feature(
        geometry: Polygon(coordinates: multiCoords), properties: properties);
  } else {
    throw Exception(
        "geometry type  ${(geom as GeoJSONObject).type}  is not supported");
  }
}

/// Auto Completes Coords - matches first & last coordinates
List<Position> _autoCompleteCoords(List<Position> coords) {
  var first = coords[0];
  var x1 = first[0];
  var y1 = first[1];
  var last = coords[coords.length - 1];
  var x2 = last[0];
  var y2 = last[1];
  if (x1 != x2 || y1 != y2) {
    coords.add(first);
  }
  return coords;
}

/// Quick calculates approximate area (used to sort)
num _calculateArea(BBox bbox) {
  var west = bbox[0];
  var south = bbox[1];
  var east = bbox[2];
  var north = bbox[3];
  return (west! - east!).abs() * (south! - north!).abs();
}
