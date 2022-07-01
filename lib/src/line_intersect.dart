
import '../helpers.dart';


/// Takes any LineString or Polygon GeoJSON and returns the intersecting point(s).
/// @name lineIntersect
/// @param {GeoJSON} line1 any LineString or Polygon
/// @param {GeoJSON} line2 any LineString or Polygon
/// @param {Object} [options={}] Optional parameters
/// @param {boolean} [options.removeDuplicates=true] remove duplicate intersections
/// @param {boolean} [options.ignoreSelfIntersections=false] ignores self-intersections on input features
/// @returns {FeatureCollection<Point>} point(s) that intersect both
/// @example
/// var line1 = turf.lineString([[126, -11], [129, -21]]);
/// var line2 = turf.lineString([[123, -18], [131, -14]]);
/// var intersects = turf.lineIntersect(line1, line2);
/// //addToMap
/// var addToMap = [line1, line2, intersects]

FeatureCollection<Point>  lineIntersect(
  GeoJSONObject line1,
 GeoJSONObject line2,
{
   bool removeDuplicates = true,
  bool  ignoreSelfIntersections = false
  }
){
  var features= <Feature>[];
  if (line1 is FeatureCollection)
{    features = features..addAll((line1 as FeatureCollection).features);
}  else if (line1 is Feature) {features.add(line1);}
  else if (
    line1 is LineString ||
    line1 is Polygon ||
    line1 is MultiLineString ||
    line1 is MultiPolygon
  ) {
    features.add(Feature(geometry: line1 as GeometryObject));
  }

  if (line2 is FeatureCollection)
    {features = features..addAll(line2.features);}
  else if (line2 is Feature) {features.add(line2);}
  else if (
    line2 is LineString ||
    line2 is Polygon ||
    line2 is MultiLineString ||
    line2 is MultiPolygon
  ) {
    features.add(Feature(geometry: line2 as GeometryObject));
  }

  var intersections = findIntersections(
    FeatureCollection(features: features),
    ignoreSelfIntersections
  );

  var results: Intersection[] = [];
  if (removeDuplicates) {
    const unique: Record<string, boolean> = {};
    intersections.forEach((intersection) => {
      var key = intersection.join(",");
      if (!unique[key]) {
        unique[key] = true;
        results.push(intersection);
      }
    });
  } else {
    results = intersections;
  }
  return FeatureCollection(features: results.map((r) => Feature(geometry: Point(coordinates:r))));
}


/** 
 * import { feature, featureCollection, point } from "@turf/helpers";
import {
  Feature,
  FeatureCollection,
  LineString,
  MultiLineString,
  MultiPolygon,
  Point,
  Polygon,
} from "geojson";
import findIntersections, { Intersection } from "sweepline-intersections";

/**
 * Takes any LineString or Polygon GeoJSON and returns the intersecting point(s).
 *
 * @name lineIntersect
 * @param {GeoJSON} line1 any LineString or Polygon
 * @param {GeoJSON} line2 any LineString or Polygon
 * @param {Object} [options={}] Optional parameters
 * @param {boolean} [options.removeDuplicates=true] remove duplicate intersections
 * @param {boolean} [options.ignoreSelfIntersections=false] ignores self-intersections on input features
 * @returns {FeatureCollection<Point>} point(s) that intersect both
 * @example
 * var line1 = turf.lineString([[126, -11], [129, -21]]);
 * var line2 = turf.lineString([[123, -18], [131, -14]]);
 * var intersects = turf.lineIntersect(line1, line2);
 *
 * //addToMap
 * var addToMap = [line1, line2, intersects]
 */
function lineIntersect<
  G1 extends LineString | MultiLineString | Polygon | MultiPolygon,
  G2 extends LineString | MultiLineString | Polygon | MultiPolygon
>(
  line1: FeatureCollection<G1> | Feature<G1> | G1,
  line2: FeatureCollection<G2> | Feature<G2> | G2,
  options: {
    removeDuplicates?: boolean;
    ignoreSelfIntersections?: boolean;
  } = {}
): FeatureCollection<Point> {
  const { removeDuplicates = true, ignoreSelfIntersections = false } = options;
  let features: Feature<G1 | G2>[] = [];
  if (line1.type === "FeatureCollection")
    features = features.concat(line1.features);
  else if (line1.type === "Feature") features.push(line1);
  else if (
    line1.type === "LineString" ||
    line1.type === "Polygon" ||
    line1.type === "MultiLineString" ||
    line1.type === "MultiPolygon"
  ) {
    features.push(feature(line1));
  }

  if (line2.type === "FeatureCollection")
    features = features.concat(line2.features);
  else if (line2.type === "Feature") features.push(line2);
  else if (
    line2.type === "LineString" ||
    line2.type === "Polygon" ||
    line2.type === "MultiLineString" ||
    line2.type === "MultiPolygon"
  ) {
    features.push(feature(line2));
  }

  const intersections = findIntersections(
    featureCollection(features),
    ignoreSelfIntersections
  );

  let results: Intersection[] = [];
  if (removeDuplicates) {
    const unique: Record<string, boolean> = {};
    intersections.forEach((intersection) => {
      const key = intersection.join(",");
      if (!unique[key]) {
        unique[key] = true;
        results.push(intersection);
      }
    });
  } else {
    results = intersections;
  }
  return featureCollection(results.map((r) => point(r)));
}

export default lineIntersect;
 */