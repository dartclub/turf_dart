

// To-Do => Improve Typescript GeoJSON handling

import '../helpers.dart';
import 'invariant.dart';


/// Removes redundant coordinates from any GeoJSON Geometry.
/// @name cleanCoords
/// @param {Geometry|Feature} geojson Feature or Geometry
/// @param {Object} [options={}] Optional parameters
/// @param {boolean} [options.mutate=false] allows GeoJSON input to be mutated
/// @returns {Geometry|Feature} the cleaned input Feature/Geometry
/// @example
/// var line = turf.lineString([[0, 0], [0, 2], [0, 5], [0, 8], [0, 8], [0, 10]]);
/// var multiPoint = turf.multiPoint([[0, 0], [0, 0], [2, 2]]);
/// turf.cleanCoords(line).geometry.coordinates;
/// //= [[0, 0], [0, 10]]
/// turf.cleanCoords(multiPoint).geometry.coordinates;
/// //= [[0, 0], [2, 2]]
 cleanCoords(
  GeoJSONObject geojson,
  {
    bool mutate,
  } 
) {
  // // Backwards compatible with v4.0
  // var mutate = typeof options == "object" ? options.mutate : options;
  // if (!geojson) throw Exception("geojson is required");
  var type = (geojson.type);

  // Store new "clean" points in this Array
  var newCoords = [];

  switch (type) {
    case GeoJSONObjectType.lineString:
      newCoords = cleanLine(geojson as LineString, type);
      break;
    case GeoJSONObjectType.multiLineString:
    case GeoJSONObjectType.polygon:
      getCoords(geojson).forEach( (line) {
        newCoords.add(cleanLine(line, type));
      });
      break;
    case GeoJSONObjectType.multiPolygon:
      getCoords(geojson).forEach( (polygons) {
        var polyPoints = <Position>[];
        polygons.forEach( (List<Position> ring) {
          polyPoints.add(cleanLine(ring, type));
        });
        newCoords.add(polyPoints);
      });
      break;
    case GeoJSONObjectType.point:
      return geojson;
    case GeoJSONObjectType.multiPoint:
      var Record<string, true> existing:  = {};
      getCoords(geojson).forEach( (coord: any) {
        var key = coord.join("-");
        if (!Object.prototype.hasOwnProperty.call(existing, key)) {
          newCoords.add(coord);
          existing[key] = true;
        }
      });
      break;
    default:
      throw Exception(type + " geometry not supported");
  }

  // Support input mutation
  if (geojson.coordinates) {
    if (mutate) {
      geojson.coordinates = newCoords;
      return geojson;
    }
    return { type: type, coordinates: newCoords };
  } else {
    if (mutate) {
      geojson.geometry.coordinates = newCoords;
      return geojson;
    }
    return feature({ type: type, coordinates: newCoords }, geojson.properties, {
      bbox: geojson.bbox,
      id: geojson.id,
    });
  }
}

/**
 * Clean Coords
 *
 * @private
 * @param {Array<number>|LineString} line Line
 * @param {string} type Type of geometry
 * @returns {Array<number>} Cleaned coordinates
 */
 cleanLine(dynamic line, GeoJSONObjectType type) {
  var points = getCoords(line);
  // handle "clean" segment
  if (points.length == 2 && !equals(points[0], points[1])) return points;

  var newPoints = [];
  var secondToLast = points.length - 1;
  var newPointsLength = newPoints.length;

  newPoints.add(points[0]);
  for (var i = 1; i < secondToLast; i++) {
    var prevAddedPoint = newPoints[newPoints.length - 1];
    if (
      points[i][0] == prevAddedPoint[0] &&
      points[i][1] == prevAddedPoint[1]
    )
{      continue;
}    else {
      newPoints.add(points[i]);
      newPointsLength = newPoints.length;
      if (newPointsLength > 2) {
        if (
          isPointOnLineSegment(
            newPoints[newPointsLength - 3],
            newPoints[newPointsLength - 1],
            newPoints[newPointsLength - 2]
          )
        )
{          newPoints.removeAt(newPoints.length - 2);
}      }
    }
  }
  newPoints.add(points[points.length - 1]);
  newPointsLength = newPoints.length;

  // (Multi)Polygons must have at least 4 points, but a closed LineString with only 3 points is acceptable
  if (
    (type is Polygon || type is MultiPolygon) &&
    equals(points[0], points[points.length - 1]) &&
    newPointsLength < 4
  ) {
    throw Exception("invalid polygon");
  }

  if (
    isPointOnLineSegment(
      newPoints[newPointsLength - 3],
      newPoints[newPointsLength - 1],
      newPoints[newPointsLength - 2]
    )
  )
{    newPoints.removeAt(newPoints.length - 2);
}
  return newPoints;
}

/**
 * Compares two points and returns if they are equals
 *
 * @private
 * @param {Position} pt1 point
 * @param {Position} pt2 point
 * @returns {boolean} true if they are equals
 */
 equals(Position pt1 , Position pt2 ) {
  return pt1[0] == pt2[0] && pt1[1] == pt2[1];
}

/**
 * Returns if `point` is on the segment between `start` and `end`.
 * Borrowed from `@turf/boolean-point-on-line` to speed up the evaluation (instead of using the module as dependency)
 *
 * @private
 * @param {Position} start coord pair of start of line
 * @param {Position} end coord pair of end of line
 * @param {Position} point coord pair of point to check
 * @returns {boolean} true/false
 */
 isPointOnLineSegment(Position start , Position end , Position point ) {
  var x = point[0],
    y = point[1];
  var startX = start[0],
    startY = start[1];
  var endX = end[0],
    endY = end[1];

  var dxc = x! - startX!;
  var dyc = y! - startY!;
  var dxl = endX! - startX;
  var dyl = endY! - startY;
  var cross = dxc * dyl - dyc * dxl;

  if (cross != 0){ return false;}
  else if ((dxl).abs() >= (dyl).abs())
{    return dxl > 0 ? startX <= x && x <= endX : endX <= x && x <= startX;
}  else {return dyl > 0 ? startY <= y && y <= endY : endY <= y && y <= startY;}
}

/**
 * import { Position } from "geojson";
import { feature } from "@turf/helpers";
import { getCoords, getType } from "@turf/invariant";

// To-Do => Improve Typescript GeoJSON handling

/**
 * Removes redundant coordinates from any GeoJSON Geometry.
 *
 * @name cleanCoords
 * @param {Geometry|Feature} geojson Feature or Geometry
 * @param {Object} [options={}] Optional parameters
 * @param {boolean} [options.mutate=false] allows GeoJSON input to be mutated
 * @returns {Geometry|Feature} the cleaned input Feature/Geometry
 * @example
 * var line = turf.lineString([[0, 0], [0, 2], [0, 5], [0, 8], [0, 8], [0, 10]]);
 * var multiPoint = turf.multiPoint([[0, 0], [0, 0], [2, 2]]);
 *
 * turf.cleanCoords(line).geometry.coordinates;
 * //= [[0, 0], [0, 10]]
 *
 * turf.cleanCoords(multiPoint).geometry.coordinates;
 * //= [[0, 0], [2, 2]]
 */
 cleanCoords(
  geojson: any,
  options: {
    mutate?: boolean;
  } = {}
) {
  // Backwards compatible with v4.0
  var mutate = typeof options == "object" ? options.mutate : options;
  if (!geojson) throw new Error("geojson is required");
  var type = getType(geojson);

  // Store new "clean" points in this Array
  var newCoords = [];

  switch (type) {
    case "LineString":
      newCoords = cleanLine(geojson, type);
      break;
    case "MultiLineString":
    case "Polygon":
      getCoords(geojson).forEach(function (line) {
        newCoords.push(cleanLine(line, type));
      });
      break;
    case "MultiPolygon":
      getCoords(geojson).forEach(function (polygons: any) {
        var polyPoints: Position[] = [];
        polygons.forEach(function (ring: Position[]) {
          polyPoints.push(cleanLine(ring, type));
        });
        newCoords.push(polyPoints);
      });
      break;
    case "Point":
      return geojson;
    case "MultiPoint":
      var existing: Record<string, true> = {};
      getCoords(geojson).forEach(function (coord: any) {
        var key = coord.join("-");
        if (!Object.prototype.hasOwnProperty.call(existing, key)) {
          newCoords.push(coord);
          existing[key] = true;
        }
      });
      break;
    default:
      throw new Error(type + " geometry not supported");
  }

  // Support input mutation
  if (geojson.coordinates) {
    if (mutate == true) {
      geojson.coordinates = newCoords;
      return geojson;
    }
    return { type: type, coordinates: newCoords };
  } else {
    if (mutate == true) {
      geojson.geometry.coordinates = newCoords;
      return geojson;
    }
    return feature({ type: type, coordinates: newCoords }, geojson.properties, {
      bbox: geojson.bbox,
      id: geojson.id,
    });
  }
}

/**
 * Clean Coords
 *
 * @private
 * @param {Array<number>|LineString} line Line
 * @param {string} type Type of geometry
 * @returns {Array<number>} Cleaned coordinates
 */
function cleanLine(line: Position[], type: string) {
  var points = getCoords(line);
  // handle "clean" segment
  if (points.length == 2 && !equals(points[0], points[1])) return points;

  var newPoints = [];
  var secondToLast = points.length - 1;
  var newPointsLength = newPoints.length;

  newPoints.push(points[0]);
  for (var i = 1; i < secondToLast; i++) {
    var prevAddedPoint = newPoints[newPoints.length - 1];
    if (
      points[i][0] == prevAddedPoint[0] &&
      points[i][1] == prevAddedPoint[1]
    )
      continue;
    else {
      newPoints.push(points[i]);
      newPointsLength = newPoints.length;
      if (newPointsLength > 2) {
        if (
          isPointOnLineSegment(
            newPoints[newPointsLength - 3],
            newPoints[newPointsLength - 1],
            newPoints[newPointsLength - 2]
          )
        )
          newPoints.splice(newPoints.length - 2, 1);
      }
    }
  }
  newPoints.push(points[points.length - 1]);
  newPointsLength = newPoints.length;

  // (Multi)Polygons must have at least 4 points, but a closed LineString with only 3 points is acceptable
  if (
    (type == "Polygon" || type == "MultiPolygon") &&
    equals(points[0], points[points.length - 1]) &&
    newPointsLength < 4
  ) {
    throw new Error("invalid polygon");
  }

  if (
    isPointOnLineSegment(
      newPoints[newPointsLength - 3],
      newPoints[newPointsLength - 1],
      newPoints[newPointsLength - 2]
    )
  )
    newPoints.splice(newPoints.length - 2, 1);

  return newPoints;
}

/**
 * Compares two points and returns if they are equals
 *
 * @private
 * @param {Position} pt1 point
 * @param {Position} pt2 point
 * @returns {boolean} true if they are equals
 */
function equals(pt1: Position, pt2: Position) {
  return pt1[0] == pt2[0] && pt1[1] == pt2[1];
}

/**
 * Returns if `point` is on the segment between `start` and `end`.
 * Borrowed from `@turf/boolean-point-on-line` to speed up the evaluation (instead of using the module as dependency)
 *
 * @private
 * @param {Position} start coord pair of start of line
 * @param {Position} end coord pair of end of line
 * @param {Position} point coord pair of point to check
 * @returns {boolean} true/false
 */
function isPointOnLineSegment(start: Position, end: Position, point: Position) {
  var x = point[0],
    y = point[1];
  var startX = start[0],
    startY = start[1];
  var endX = end[0],
    endY = end[1];

  var dxc = x - startX;
  var dyc = y - startY;
  var dxl = endX - startX;
  var dyl = endY - startY;
  var cross = dxc * dyl - dyc * dxl;

  if (cross !== 0) return false;
  else if (Math.abs(dxl) >= Math.abs(dyl))
    return dxl > 0 ? startX <= x && x <= endX : endX <= x && x <= startX;
  else return dyl > 0 ? startY <= y && y <= endY : endY <= y && y <= startY;
}

export default cleanCoords;
 */