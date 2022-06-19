import 'package:turf/turf.dart';

import '../invariant.dart';
import 'boolean_point_in_polygon.dart';
import 'boolean_point_on_line.dart';

/**
 * Boolean-contains returns True if the second geometry is completely contained by the first geometry.
 * The interiors of both geometries must intersect and, the interior and boundary of the secondary (geometry b)
 * must not intersect the exterior of the primary (geometry a).
 * Boolean-contains returns the exact opposite result of the `@turf/boolean-within`.
 *
 * @name booleanContains
 * @param {Geometry|Feature<any>} feature1 GeoJSON Feature or Geometry
 * @param {Geometry|Feature<any>} feature2 GeoJSON Feature or Geometry
 * @returns {boolean} true/false
 * @example
 * var line = turf.lineString([[1, 1], [1, 2], [1, 3], [1, 4]]);
 * var point = turf.point([1, 2]);
 *
 * turf.booleanContains(line, point);
 * //=true
 */
booleanContains(GeoJSONObject feature1, GeoJSONObject feature2) {
  var geom1 = getGeom(feature1);
  var geom2 = getGeom(feature2);
  var type1 = geom1.runtimeType;
  var type2 = geom2.runtimeType;
  var coords1 = geom1.coordinates;
  var coords2 = geom2.coordinates;

  switch (type1) {
    case Point:
      switch (type2) {
        case Point:
          return compareCoords(coords1, coords2);
        default:
          throw UnsupportedError(
              "{feature2   $type2   geometry not supported}");
      }
    case MultiPoint:
      switch (type2) {
        case Point:
          return isPointInMultiPoint(geom1, geom2);
        case MultiPoint:
          return isMultiPointInMultiPoint(geom1, geom2);
        default:
          throw UnsupportedError(
              "{feature2   $type2   geometry not supported}");
      }
    case LineString:
      switch (type2) {
        case Point:
          return booleanPointOnLine(geom2, geom1, ignoreEndVertices: true);
        case LineString:
          return isLineOnLine(geom1, geom2);
        case MultiPoint:
          return isMultiPointOnLine(geom1, geom2);
        default:
          throw UnsupportedError(
              "{feature2   $type2   geometry not supported}");
      }
    case Polygon:
      switch (type2) {
        case Point:
          return booleanPointInPolygon(geom2, geom1, ignoreBoundary: true);
        case LineString:
          return isLineInPoly(geom1, geom2);
        case Polygon:
          return isPolyInPoly(geom1, geom2);
        case MultiPoint:
          return isMultiPointInPoly(geom1, geom2);
        default:
          throw UnsupportedError(
              "{feature2   $type2   geometry not supported}");
      }
    default:
      throw UnsupportedError("feature1  $type1 geometry not supported");
  }
}

isPointInMultiPoint(MultiPoint multiPoint, Point pt) {
  int i;
  var output = false;
  for (i = 0; i < multiPoint.coordinates.length; i++) {
    if (compareCoords(multiPoint.coordinates[i], pt.coordinates)) {
      output = true;
      break;
    }
  }
  return output;
}

isMultiPointInMultiPoint(MultiPoint multiPoint1, MultiPoint multiPoint2) {
  for (var coord2 in multiPoint2.coordinates) {
    var matchFound = false;
    for (var coord1 in multiPoint1.coordinates) {
      if (compareCoords(coord2, coord1)) {
        matchFound = true;
        break;
      }
    }
    if (!matchFound) {
      return false;
    }
  }
  return true;
}

isMultiPointOnLine(LineString lineString, MultiPoint multiPoint) {
  var haveFoundInteriorPoint = false;
  for (var coord in multiPoint.coordinates) {
    if (booleanPointOnLine(Point(coordinates: coord), lineString,
        ignoreEndVertices: true)) {
      haveFoundInteriorPoint = true;
    }
    if (!booleanPointOnLine(Point(coordinates: coord), lineString)) {
      return false;
    }
  }
  if (haveFoundInteriorPoint) {
    return true;
  }
  return false;
}

isMultiPointInPoly(Polygon polygon, MultiPoint multiPoint) {
  for (var coord in multiPoint.coordinates) {
    if (!booleanPointInPolygon(coord, polygon, ignoreBoundary: true)) {
      return false;
    }
  }
  return true;
}

isLineOnLine(LineString lineString1, LineString lineString2) {
  var haveFoundInteriorPoint = false;
  for (var coords in lineString2.coordinates) {
    if (booleanPointOnLine(
      Point(coordinates: coords),
      lineString1,
      ignoreEndVertices: true,
    )) {
      haveFoundInteriorPoint = true;
    }
    if (!booleanPointOnLine(
      Point(coordinates: coords),
      lineString1,
      ignoreEndVertices: false,
    )) {
      return false;
    }
  }
  return haveFoundInteriorPoint;
}

isLineInPoly(Polygon polygon, LineString linestring) {
  var output = false;
  var i = 0;

  var polyBbox = bbox(polygon);
  var lineBbox = bbox(linestring);
  if (!doBBoxOverlap(polyBbox, lineBbox)) {
    return false;
  }
  for (i; i < linestring.coordinates.length - 1; i++) {
    var midPoint =
        getMidpoint(linestring.coordinates[i], linestring.coordinates[i + 1]);
    if (booleanPointInPolygon(
      Position.of(midPoint),
      polygon,
      ignoreBoundary: true,
    )) {
      output = true;
      break;
    }
  }
  return output;
}

/**
 * Is Polygon2 in Polygon1
 * Only takes into account outer rings
 *
 * @private
 * @param {Geometry|Feature<Polygon>} feature1 Polygon1
 * @param {Geometry|Feature<Polygon>} feature2 Polygon2
 * @returns {boolean} true/false
 */
isPolyInPoly(GeoJSONObject feature1, GeoJSONObject feature2) {
  // Handle Nulls
  if (feature1 is Feature && feature1.geometry == null) {
    return false;
  }
  if (feature2 is Feature && feature2.geometry == null) {
    return false;
  }

  var poly1Bbox = bbox(feature1);
  var poly2Bbox = bbox(feature2);
  if (!doBBoxOverlap(poly1Bbox, poly2Bbox)) {
    return false;
  }

  var coords = (feature2 as Feature<GeometryType>).geometry!.coordinates;
  for (var ring in coords) {
    for (var coord in ring) {
      if (!booleanPointInPolygon(coord, feature1 as Feature)) {
        return false;
      }
    }
  }
  return true;
}

doBBoxOverlap(BBox bbox1, BBox bbox2) {
  if (bbox1[0]! > bbox2[0]!) {
    return false;
  }
  if (bbox1[2]! < bbox2[2]!) {
    return false;
  }
  if (bbox1[1]! > bbox2[1]!) {
    return false;
  }
  if (bbox1[3]! < bbox2[3]!) {
    return false;
  }
  return true;
}

/**
 * compareCoords
 *
 * @private
 * @param {Position} pair1 point [x,y]
 * @param {Position} pair2 point [x,y]
 * @returns {boolean} true/false if coord pairs match
 */
compareCoords(Position pair1, Position pair2) {
  return pair1[0] == pair2[0] && pair1[1] == pair2[1];
}

getMidpoint(Position pair1, Position pair2) {
  return [(pair1[0]! + pair2[0]!) / 2, (pair1[1]! + pair2[1]!) / 2];
}

/*
import {
  BBox,
  Feature,
  Geometry,
  LineString,
  MultiPoint,
  Point,
  Polygon,
} from "geojson";
import calcBbox from "@turf/bbox";
import booleanPointInPolygon from "@turf/boolean-point-in-polygon";
import isPointOnLine from "@turf/boolean-point-on-line";
import { getGeom } from "@turf/invariant";

/**
 * Boolean-contains returns True if the second geometry is completely contained by the first geometry.
 * The interiors of both geometries must intersect and, the interior and boundary of the secondary (geometry b)
 * must not intersect the exterior of the primary (geometry a).
 * Boolean-contains returns the exact opposite result of the `@turf/boolean-within`.
 *
 * @name booleanContains
 * @param {Geometry|Feature<any>} feature1 GeoJSON Feature or Geometry
 * @param {Geometry|Feature<any>} feature2 GeoJSON Feature or Geometry
 * @returns {boolean} true/false
 * @example
 * var line = turf.lineString([[1, 1], [1, 2], [1, 3], [1, 4]]);
 * var point = turf.point([1, 2]);
 *
 * turf.booleanContains(line, point);
 * //=true
 */
export default function booleanContains(
  feature1: Feature<any> | Geometry,
  feature2: Feature<any> | Geometry
) {
  const geom1 = getGeom(feature1);
  const geom2 = getGeom(feature2);
  const type1 = geom1.type;
  const type2 = geom2.type;
  const coords1 = geom1.coordinates;
  const coords2 = geom2.coordinates;

  switch (type1) {
    case "Point":
      switch (type2) {
        case "Point":
          return compareCoords(coords1, coords2);
        default:
          throw new Error("feature2 " + type2 + " geometry not supported");
      }
    case "MultiPoint":
      switch (type2) {
        case "Point":
          return isPointInMultiPoint(geom1, geom2);
        case "MultiPoint":
          return isMultiPointInMultiPoint(geom1, geom2);
        default:
          throw new Error("feature2 " + type2 + " geometry not supported");
      }
    case "LineString":
      switch (type2) {
        case "Point":
          return isPointOnLine(geom2, geom1, { ignoreEndVertices: true });
        case "LineString":
          return isLineOnLine(geom1, geom2);
        case "MultiPoint":
          return isMultiPointOnLine(geom1, geom2);
        default:
          throw new Error("feature2 " + type2 + " geometry not supported");
      }
    case "Polygon":
      switch (type2) {
        case "Point":
          return booleanPointInPolygon(geom2, geom1, { ignoreBoundary: true });
        case "LineString":
          return isLineInPoly(geom1, geom2);
        case "Polygon":
          return isPolyInPoly(geom1, geom2);
        case "MultiPoint":
          return isMultiPointInPoly(geom1, geom2);
        default:
          throw new Error("feature2 " + type2 + " geometry not supported");
      }
    default:
      throw new Error("feature1 " + type1 + " geometry not supported");
  }
}

export function isPointInMultiPoint(multiPoint: MultiPoint, pt: Point) {
  let i;
  let output = false;
  for (i = 0; i < multiPoint.coordinates.length; i++) {
    if (compareCoords(multiPoint.coordinates[i], pt.coordinates)) {
      output = true;
      break;
    }
  }
  return output;
}

export function isMultiPointInMultiPoint(
  multiPoint1: MultiPoint,
  multiPoint2: MultiPoint
) {
  for (const coord2 of multiPoint2.coordinates) {
    let matchFound = false;
    for (const coord1 of multiPoint1.coordinates) {
      if (compareCoords(coord2, coord1)) {
        matchFound = true;
        break;
      }
    }
    if (!matchFound) {
      return false;
    }
  }
  return true;
}

export function isMultiPointOnLine(
  lineString: LineString,
  multiPoint: MultiPoint
) {
  let haveFoundInteriorPoint = false;
  for (const coord of multiPoint.coordinates) {
    if (isPointOnLine(coord, lineString, { ignoreEndVertices: true })) {
      haveFoundInteriorPoint = true;
    }
    if (!isPointOnLine(coord, lineString)) {
      return false;
    }
  }
  if (haveFoundInteriorPoint) {
    return true;
  }
  return false;
}

export function isMultiPointInPoly(polygon: Polygon, multiPoint: MultiPoint) {
  for (const coord of multiPoint.coordinates) {
    if (!booleanPointInPolygon(coord, polygon, { ignoreBoundary: true })) {
      return false;
    }
  }
  return true;
}

export function isLineOnLine(lineString1: LineString, lineString2: LineString) {
  let haveFoundInteriorPoint = false;
  for (const coords of lineString2.coordinates) {
    if (
      isPointOnLine({ type: "Point", coordinates: coords }, lineString1, {
        ignoreEndVertices: true,
      })
    ) {
      haveFoundInteriorPoint = true;
    }
    if (
      !isPointOnLine({ type: "Point", coordinates: coords }, lineString1, {
        ignoreEndVertices: false,
      })
    ) {
      return false;
    }
  }
  return haveFoundInteriorPoint;
}

export function isLineInPoly(polygon: Polygon, linestring: LineString) {
  let output = false;
  let i = 0;

  const polyBbox = calcBbox(polygon);
  const lineBbox = calcBbox(linestring);
  if (!doBBoxOverlap(polyBbox, lineBbox)) {
    return false;
  }
  for (i; i < linestring.coordinates.length - 1; i++) {
    const midPoint = getMidpoint(
      linestring.coordinates[i],
      linestring.coordinates[i + 1]
    );
    if (
      booleanPointInPolygon({ type: "Point", coordinates: midPoint }, polygon, {
        ignoreBoundary: true,
      })
    ) {
      output = true;
      break;
    }
  }
  return output;
}

/**
 * Is Polygon2 in Polygon1
 * Only takes into account outer rings
 *
 * @private
 * @param {Geometry|Feature<Polygon>} feature1 Polygon1
 * @param {Geometry|Feature<Polygon>} feature2 Polygon2
 * @returns {boolean} true/false
 */
export function isPolyInPoly(
  feature1: Feature<Polygon> | Polygon,
  feature2: Feature<Polygon> | Polygon
) {
  // Handle Nulls
  if (feature1.type === "Feature" && feature1.geometry === null) {
    return false;
  }
  if (feature2.type === "Feature" && feature2.geometry === null) {
    return false;
  }

  const poly1Bbox = calcBbox(feature1);
  const poly2Bbox = calcBbox(feature2);
  if (!doBBoxOverlap(poly1Bbox, poly2Bbox)) {
    return false;
  }

  const coords = getGeom(feature2).coordinates;
  for (const ring of coords) {
    for (const coord of ring) {
      if (!booleanPointInPolygon(coord, feature1)) {
        return false;
      }
    }
  }
  return true;
}

export function doBBoxOverlap(bbox1: BBox, bbox2: BBox) {
  if (bbox1[0] > bbox2[0]) {
    return false;
  }
  if (bbox1[2] < bbox2[2]) {
    return false;
  }
  if (bbox1[1] > bbox2[1]) {
    return false;
  }
  if (bbox1[3] < bbox2[3]) {
    return false;
  }
  return true;
}

/**
 * compareCoords
 *
 * @private
 * @param {Position} pair1 point [x,y]
 * @param {Position} pair2 point [x,y]
 * @returns {boolean} true/false if coord pairs match
 */
export function compareCoords(pair1: number[], pair2: number[]) {
  return pair1[0] === pair2[0] && pair1[1] === pair2[1];
}

export function getMidpoint(pair1: number[], pair2: number[]) {
  return [(pair1[0] + pair2[0]) / 2, (pair1[1] + pair2[1]) / 2];
} */