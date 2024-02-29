//? how do we want to express this?

//* Here's the code from the JS package
//  export type Pair = [number, number]
//   export type Ring = Pair[]
//   export type Polygon = Ring[]
//   export type MultiPolygon = Polygon[]
//   type Geom = Polygon | MultiPolygon
//   export function intersection(geom: Geom, ...geoms: Geom[]): MultiPolygon
//   export function xor(geom: Geom, ...geoms: Geom[]): MultiPolygon
//   export function union(geom: Geom, ...geoms: Geom[]): MultiPolygon
//   export function difference(
//     subjectGeom: Geom,
//     ...clipGeoms: Geom[]
//   ): MultiPolygon
//* }