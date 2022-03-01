import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';

main() {
  LineString line1 = LineString(coordinates: [Position(1, 2), Position(3, 4)]);
  var feature1 =
      Feature<Point>(geometry: Point(coordinates: Position(1, 2, 3)));
  test("invariant -- getCoord", () {
    expect(() => getCoord(line1), throwsA(isA<Exception>()));
    expect(() => getCoord(null), throwsA(isA<Exception>()));
    expect(() => getCoord(false), throwsA(isA<Exception>()));
    expect(getCoord(feature1.geometry), Position(1, 2, 3));
    expect(getCoord(feature1), Position(1, 2, 3));
    expect(getCoord(feature1.geometry!.coordinates), Position(1, 2, 3));
  });

  test("invariant -- getCoords", () {
    var feature2 = Feature<LineString>(geometry: line1);
    expect(() => getCoords(null), throwsA(isA<Exception>()));
    expect(() => getCoords(feature1), throwsA(isA<Exception>())); 
    var coords = getCoords(feature2);
    expect(coords.length, feature2.geometry!.coordinates.length);
    expect(coords.first, feature2.geometry!.coordinates.first);
    expect(coords.last, feature2.geometry!.coordinates.last);

  });
/*

test("invariant -- getCoords", (t) => {

}

  t.throws(() =>
    invariant.getCoords({
      type: "LineString",
      coordinates: null,
    })
  );

  t.throws(() => invariant.getCoords(false));
  t.throws(() => invariant.getCoords(null));
  t.throws(() =>
    invariant.containsNumber(invariant.getCoords(["A", "B", "C"]))
  );
  t.throws(() =>
    invariant.containsNumber(invariant.getCoords([1, "foo", "bar"]))
  );

  t.deepEqual(
    invariant.getCoords({
      type: "LineString",
      coordinates: [
        [1, 2],
        [3, 4],
      ],
    }),
    [
      [1, 2],
      [3, 4],
    ]
  );

  t.deepEqual(invariant.getCoords(point([1, 2])), [1, 2]);
  t.deepEqual(
    invariant.getCoords(
      lineString([
        [1, 2],
        [3, 4],
      ])
    ),
    [
      [1, 2],
      [3, 4],
    ]
  );
  t.deepEqual(invariant.getCoords([1, 2]), [1, 2]);
  t.end();
});
*/
}
