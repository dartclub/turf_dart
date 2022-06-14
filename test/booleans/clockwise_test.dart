import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_clockwise.dart';

main() {
  // test("isClockwise#fixtures", () {
  // // True Fixtures
  // glob
  //   .sync(path.join(__dirname, "test", "true", "*.geojson"))
  //   .forEach((filepath) => {
  //     const name = path.parse(filepath).name;
  //     const geojson = load.sync(filepath);
  //     const feature = geojson.features[0];
  //     t.true(isClockwise(feature), "[true] " + name);
  //   });
  // // False Fixtures
  // glob
  //   .sync(path.join(__dirname, "test", "false", "*.geojson"))
  //   .forEach((filepath) => {
  //     const name = path.parse(filepath).name;
  //     const geojson = load.sync(filepath);
  //     const feature = geojson.features[0];
  //     t.false(isClockwise(feature), "[false] " + name);
  //   });
  // t.end();
  // });

  test("isClockwise", () {
    const cwArray = [
      [0, 0],
      [1, 1],
      [1, 0],
      [0, 0],
    ];
    const ccwArray = [
      [0, 0],
      [1, 0],
      [1, 1],
      [0, 0],
    ];

    expect(
      booleanClockwise(cwArray),
      equals(
        true,
      ),
    );

    expect(
      booleanClockwise(ccwArray),
      equals(false),
    );
  });

  test("isClockwise -- Geometry types", () {
    LineString line = LineString(coordinates: [
      Position.of([0, 0]),
      Position.of([1, 1]),
      Position.of([1, 0]),
      Position.of([0, 0]),
    ]);

    expect(booleanClockwise(line), equals(true));
    expect(booleanClockwise(line.coordinates), equals(true));
  });

// test('isClockwise -- throws', t => {
//     const pt = point([-10, -33]);
//     t.throws(() => isClockwise(pt), 'feature geometry not supported');

//     t.end();
// });
}
