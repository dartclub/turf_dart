import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_concave.dart';

main() {
// test("isConcave#fixtures", (t) => {
//   // True Fixtures
//   glob
//     .sync(path.join(__dirname, "test", "true", "*.geojson"))
//     .forEach((filepath) => {
//       const name = path.parse(filepath).name;
//       const geojson = load.sync(filepath);
//       const feature = geojson.features[0];
//       t.true(isConcave(feature), "[true] " + name);
//     });
//   // False Fixtures
//   glob
//     .sync(path.join(__dirname, "test", "false", "*.geojson"))
//     .forEach((filepath) => {
//       const name = path.parse(filepath).name;
//       const geojson = load.sync(filepath);
//       const feature = geojson.features[0];
//       t.false(isConcave(feature), "[false] " + name);
//     });
//   t.end();
// });

  test("isConcave -- Geometry types", () {
    var featureCollection = FeatureCollection(features: [
      Feature(
          properties: {},
          geometry: Polygon(coordinates: [
            [
              Position.of([0.85418701171875, 1.06286628163273]),
              Position.of([0.46966552734375, 0.7909904981540058]),
              Position.of([0.6619262695312499, 0.5712795966325395]),
              Position.of([0.77178955078125, 0.856901647439813]),
              Position.of([0.736083984375, 0.8514090937773031]),
              Position.of([0.6591796875, 0.8129610018708315]),
              Position.of([0.6921386718749999, 0.884364296613886]),
              Position.of([0.9173583984375001, 0.8898568022677679]),
              Position.of([1.07391357421875, 0.8129610018708315]),
              Position.of([1.0876464843749998, 0.9392889790847924]),
              Position.of([1.0052490234375, 1.0271666545523288]),
              Position.of([0.85418701171875, 1.06286628163273]),
            ]
          ]))
    ]);

    Polygon poly = Polygon(coordinates: [
      [
        Position.of([0, 0]),
        Position.of([0, 1]),
        Position.of([1, 1]),
        Position.of([1, 0]),
        Position.of([0, 0]),
      ],
    ]);

    expect(booleanConcave(poly), equals(false));
    expect(booleanConcave(featureCollection.features.first.geometry!),
        equals(true));
  });
}
