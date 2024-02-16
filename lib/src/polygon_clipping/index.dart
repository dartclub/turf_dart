import 'operation.dart';

//?Should these just be methods of operations? or factory constructors or something else?
dynamic union(dynamic geom, List<dynamic> moreGeoms) =>
    operation.run("union", geom, moreGeoms);

dynamic intersection(dynamic geom, List<dynamic> moreGeoms) =>
    operation.run("intersection", geom, moreGeoms);

dynamic xor(dynamic geom, List<dynamic> moreGeoms) =>
    operation.run("xor", geom, moreGeoms);

dynamic difference(dynamic subjectGeom, List<dynamic> clippingGeoms) =>
    operation.run("difference", subjectGeom, clippingGeoms);

Map<String, Function> operations = {
  'union': union,
  'intersection': intersection,
  'xor': xor,
  'difference': difference,
};
