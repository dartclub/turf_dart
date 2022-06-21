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
/// var line = LineString(coordinates: [[125, -30], [145, -30], [145, -20], [125, -20], [125, -30]]);
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
    bool isEitherMultiLineStringOrLineString = true;

    if (isEitherMultiLineStringOrLineString) {
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
    }
  } else if (lines is Feature) {
    if (lines.geometry is LineString) {
      lines = Feature<LineString>(geometry: lines.geometry as LineString);
    } else if (lines.geometry is MultiLineString) {
      lines =
          Feature<MultiLineString>(geometry: lines.geometry as MultiLineString);
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
/// Takes an optional orderCoords=true that sorts linestrings to place outer ring at the first position of the coordinates
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

/**
 * import {
  Feature,
  FeatureCollection,
  MultiLineString,
  LineString,
  GeoJsonProperties,
  BBox,
  Position,
} from "geojson";
import turfBBox from "@turf/bbox";
import { getCoords, getGeom } from "@turf/invariant";
import { polygon, multiPolygon, lineString } from "@turf/helpers";
import clone from "@turf/clone";

/**
 * Converts (Multi)LineString(s) to Polygon(s).
 *
 * @name lineToPolygon
 * @param {FeatureCollection|Feature<LineString|MultiLineString>} lines Features to convert
 * @param {Object} [options={}] Optional parameters
 * @param {Object} [options.properties={}] translates GeoJSON properties to Feature
 * @param {boolean} [options.autoComplete=true] auto complete linestrings (matches first & last coordinates)
 * @param {boolean} [options.orderCoords=true] sorts linestrings to place outer ring at the first position of the coordinates
 * @param {boolean} [options.mutate=false] mutate the original linestring using autoComplete (matches first & last coordinates)
 * @returns {Feature<Polygon|MultiPolygon>} converted to Polygons
 * @example
 * var line = turf.lineString([[125, -30], [145, -30], [145, -20], [125, -20], [125, -30]]);
 *
 * var polygon = turf.lineToPolygon(line);
 *
 * //addToMap
 * var addToMap = [polygon];
 */
function lineToPolygon<G extends LineString | MultiLineString>(
  lines: Feature<G> | FeatureCollection<G> | G,
  options: {
    properties?: GeoJsonProperties;
    autoComplete?: boolean;
    orderCoords?: boolean;
    mutate?: boolean;
  } = {}
) {
  // Optional parameters
  var properties = options.properties;
  var autoComplete = options.autoComplete ?? true;
  var orderCoords = options.orderCoords ?? true;
  var mutate = options.mutate ?? false;

  if (!mutate) {
    lines = clone(lines);
  }

  switch (lines.type) {
    case "FeatureCollection":
      var coords: number[][][][] = [];
      lines.features.forEach(function (line) {
        coords.push(
          getCoords(lineStringToPolygon(line, {}, autoComplete, orderCoords))
        );
      });
      return multiPolygon(coords, properties);
    default:
      return lineStringToPolygon(lines, properties, autoComplete, orderCoords);
  }
}

/**
 * LineString to Polygon
 *
 * @private
 * @param {Feature<LineString|MultiLineString>} line line
 * @param {Object} [properties] translates GeoJSON properties to Feature
 * @param {boolean} [autoComplete=true] auto complete linestrings
 * @param {boolean} [orderCoords=true] sorts linestrings to place outer ring at the first position of the coordinates
 * @returns {Feature<Polygon>} line converted to Polygon
 */
function lineStringToPolygon<G extends LineString | MultiLineString>(
  line: Feature<G> | G,
  properties: GeoJsonProperties | undefined,
  autoComplete: boolean,
  orderCoords: boolean
) {
  properties = properties
    ? properties
    : line.type === "Feature"
    ? line.properties
    : {};
  var geom = getGeom(line);
  var coords: Position[] | Position[][] = geom.coordinates;
  var type = geom.type;

  if (!coords.length) throw new Error("line must contain coordinates");

  switch (type) {
    case "LineString":
      if (autoComplete) coords = autoCompleteCoords(coords as Position[]);
      return polygon([coords as Position[]], properties);
    case "MultiLineString":
      var multiCoords: number[][][] = [];
      var largestArea = 0;

      (coords as Position[][]).forEach(function (coord) {
        if (autoComplete) coord = autoCompleteCoords(coord);

        // Largest LineString to be placed in the first position of the coordinates array
        if (orderCoords) {
          var area = calculateArea(turfBBox(lineString(coord)));
          if (area > largestArea) {
            multiCoords.unshift(coord);
            largestArea = area;
          } else multiCoords.push(coord);
        } else {
          multiCoords.push(coord);
        }
      });
      return polygon(multiCoords, properties);
    default:
      throw new Error("geometry type " + type + " is not supported");
  }
}

/**
 * Auto Complete Coords - matches first & last coordinates
 *
 * @private
 * @param {Array<Array<number>>} coords Coordinates
 * @returns {Array<Array<number>>} auto completed coordinates
 */
function autoCompleteCoords(coords: Position[]) {
  var first = coords[0];
  var x1 = first[0];
  var y1 = first[1];
  var last = coords[coords.length - 1];
  var x2 = last[0];
  var y2 = last[1];
  if (x1 !== x2 || y1 !== y2) {
    coords.push(first);
  }
  return coords;
}

/**
 * area - quick approximate area calculation (used to sort)
 *
 * @private
 * @param {Array<number>} bbox BBox [west, south, east, north]
 * @returns {number} very quick area calculation
 */
function calculateArea(bbox: BBox) {
  var west = bbox[0];
  var south = bbox[1];
  var east = bbox[2];
  var north = bbox[3];
  return Math.abs(west - east) * Math.abs(south - north);
}

export default lineToPolygon;
 */
