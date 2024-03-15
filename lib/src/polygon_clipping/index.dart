import 'package:turf/src/geojson.dart';

import 'operation.dart';

//?Should these just be methods of operations? or factory constructors or something else?
GeometryObject? union(GeometryObject geom, List<GeometryObject> moreGeoms) =>
    operation.run("union", geom, moreGeoms);

GeometryObject? intersection(
        GeometryObject geom, List<GeometryObject> moreGeoms) =>
    operation.run("intersection", geom, moreGeoms);

GeometryObject? xor(GeometryObject geom, List<GeometryObject> moreGeoms) =>
    operation.run("xor", geom, moreGeoms);

GeometryObject? difference(
        GeometryObject subjectGeom, List<GeometryObject> clippingGeoms) =>
    operation.run("difference", subjectGeom, clippingGeoms);

Map<String, Function> operations = {
  'union': union,
  'intersection': intersection,
  'xor': xor,
  'difference': difference,
};
