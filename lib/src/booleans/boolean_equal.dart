import 'package:geojson_equality/geojson_equality.dart';

import '../../helpers.dart';
import '../clean_coords.dart';

/// Determine whether two geometries of the same type have identical X,Y coordinate values.
/// See http://edndoc.esri.com/arcsde/9.0/general_topics/understand_spatial_relations.htm
/// [precision]=6 sets decimal precision to use when comparing coordinates
/// Returns true if the objects are equal, false otherwise
/// example:
/// var pt1 = Point(coordinates: Position.of([0, 0]));
/// var pt2 = Point(coordinates: Position.of([0, 0]));
/// var pt3 = Point(coordinates: Position.of([1, 1]));
/// booleanEqual(pt1, pt2);
/// //= true
/// booleanEqual(pt2, pt3);
/// //= false
bool booleanEqual(GeoJSONObject feature1, GeoJSONObject feature2,
    {int precision = 6}) {
  if (!(precision >= 0)) {
    throw Exception("precision must be a positive number");
  }
  var geom = feature1 is Feature ? feature1.geometry : feature1;
  var geom2 = feature2 is Feature ? feature2.geometry : feature2;

  var type1 = geom!.type;
  var type2 = geom2!.type;
  if (type1 != type2) return false;

  var equality = Equality(precision: precision);
  return equality.compare(cleanCoords(feature1), cleanCoords(feature2));
}



/** import { Feature, Geometry } from "geojson";
import GeojsonEquality from "geojson-equality";
import cleanCoords from "@turf/clean-coords";
import { getGeom } from "@turf/invariant";

/**
 * Determine whether two geometries of the same type have identical X,Y coordinate values.
 * See http://edndoc.esri.com/arcsde/9.0/general_topics/understand_spatial_relations.htm
 *
 * @name booleanEqual
 * @param {Geometry|Feature} feature1 GeoJSON input
 * @param {Geometry|Feature} feature2 GeoJSON input
 * @param {Object} [options={}] Optional parameters
 * @param {number} [options.precision=6] decimal precision to use when comparing coordinates
 * @returns {boolean} true if the objects are equal, false otherwise
 * @example
 * var pt1 = turf.point([0, 0]);
 * var pt2 = turf.point([0, 0]);
 * var pt3 = turf.point([1, 1]);
 *
 * turf.booleanEqual(pt1, pt2);
 * //= true
 * turf.booleanEqual(pt2, pt3);
 * //= false
 */
 booleanEqual(
  feature1: Feature<any> | Geometry,
  feature2: Feature<any> | Geometry,
  options: {
    precision?: number;
  } = {}
): boolean {
  let precision = options.precision;

  precision =
    precision === undefined || precision === null || isNaN(precision)
      ? 6
      : precision;

  if (typeof precision !== "number" || !(precision >= 0)) {
    throw new Error("precision must be a positive number");
  }

  const type1 = getGeom(feature1).type;
  const type2 = getGeom(feature2).type;
  if (type1 !== type2) return false;

  const equality = new GeojsonEquality({ precision: precision });
  return equality.compare(cleanCoords(feature1), cleanCoords(feature2));
}

export default booleanEqual; */