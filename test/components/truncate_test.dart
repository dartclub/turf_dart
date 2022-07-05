import 'dart:io';

import 'package:test/test.dart';

main(){
  group('truncate', (){

  var  inDir = Directory('./test/example/truncate/in');
  var  outDir = Directory('./test/example/truncate/out');



// test("turf-truncate", () {
//   for (const { filename, name, geojson } of fixtures) {
//     const { precision, coordinates } = geojson.properties || {};
//     const results = truncate(geojson, {
//       precision: precision,
//       coordinates: coordinates,
//     });

//     if (process.env.REGEN) write.sync(directories.out + filename, results);
//     t.deepEqual(results, load.sync(directories.out + filename), name);
//   }

// });

// test("turf-truncate - precision & coordinates", () {
//   t.deepEqual(
//     truncate(point([50.1234567, 40.1234567]), { precision: 3 }).geometry
//       .coordinates,
//     [50.123, 40.123],
//     "precision 3"
//   );
//   t.deepEqual(
//     truncate(point([50.1234567, 40.1234567]), { precision: 0 }).geometry
//       .coordinates,
//     [50, 40],
//     "precision 0"
//   );
//   t.deepEqual(
//     truncate(point([50, 40, 1100]), { precision: 6 }).geometry.coordinates,
//     [50, 40, 1100],
//     "coordinates default to 3"
//   );
//   t.deepEqual(
//     truncate(point([50, 40, 1100]), { precision: 6, coordinates: 2 }).geometry
//       .coordinates,
//     [50, 40],
//     "coordinates 2"
//   );

// });

// test("turf-truncate - prevent input mutation", () {
//   const pt = point([120.123, 40.123, 3000]);
//   const ptBefore = JSON.parse(JSON.stringify(pt));

//   truncate(pt, { precision: 0 });
//   t.deepEqual(ptBefore, pt, "does not mutate input");

//   truncate(pt, { precision: 0, coordinates: 2, mutate: true });
//   t.deepEqual(pt, point([120, 40]), "does mutate input");

// });
}