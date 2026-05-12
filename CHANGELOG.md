## 0.0.12

- Implements support for GeoJSON "other members" / foreign members, including JSON serialization, deserialization, cloning, and copy helpers [#222](https://github.com/dartclub/turf_dart/pull/222)
- Implements `lineclip` for clipping line strings and polygons to bounding boxes [#235](https://github.com/dartclub/turf_dart/pull/235)
- Implements `pointOnFeature`, with tests, benchmarks, examples, and generated visualization fixtures [#216](https://github.com/dartclub/turf_dart/pull/216)
- Adds library-level doc comments to all public libraries and fixes documentation reference warnings [#257](https://github.com/dartclub/turf_dart/pull/257)

## 0.0.11

- Implements `simplify` for `Feature<LineString>` [#183](https://github.com/dartclub/turf_dart/pull/183)
- Implements `circle` [#187](https://github.com/dartclub/turf_dart/pull/187)
- Implements `pointToLineDistance` [#189](https://github.com/dartclub/turf_dart/pull/189)
- Implements `lineSliceAlong` [#190](https://github.com/dartclub/turf_dart/pull/190)
- Implements `polygonTangents` [#212](https://github.com/dartclub/turf_dart/pull/212)
- Implements `square` [#213](https://github.com/dartclub/turf_dart/pull/213)
- Implements `envelope` [#215](https://github.com/dartclub/turf_dart/pull/215)
- Implements `centerOfMass` [#221](https://github.com/dartclub/turf_dart/pull/221)
- Implements `toMercator` and `toWgs84` [#230](https://github.com/dartclub/turf_dart/pull/230)
- Implements `flip` [#231](https://github.com/dartclub/turf_dart/pull/231)
- Implements `randomLineString` [#242](https://github.com/dartclub/turf_dart/pull/242)
- Implements `combine` to convert feature collections to multi-geometries [#245](https://github.com/dartclub/turf_dart/pull/245)
- Implements `flatten` to flatten Multi* geometries to their single counterparts [#246](https://github.com/dartclub/turf_dart/pull/246)
- Fixes wrong conversion from meters to yards and from meters to inches [#194](https://github.com/dartclub/turf_dart/pull/194)
- Fixes `booleanIntersects` false positive [#196](https://github.com/dartclub/turf_dart/pull/196)
- CI/CD and tooling improvements [#218](https://github.com/dartclub/turf_dart/pull/218) [#247](https://github.com/dartclub/turf_dart/pull/247) [#248](https://github.com/dartclub/turf_dart/pull/248) [#252](https://github.com/dartclub/turf_dart/pull/252)

## 0.0.10

- Implements `lineSlice` [#158](https://github.com/dartclub/turf_dart/pull/158)
- Introduce [geotypes package](https://pub.dev/packages/geotypes) for GeoJSON serialization
- Other small improvements

## 0.0.9

- Implements `length`, `along` [#153](https://github.com/dartclub/turf_dart/pull/153)
- Documentation: Improves pub.dev scores by fixing bad links in Readme.md

## 0.0.8

- Implements `transformRotate`, `rhumbDistance`, `rhumbDestination`, `centroid` [#147](https://github.com/dartclub/turf_dart/pull/147)
- Introduce `localCoordIndex` in `coordEach`
- Implements all the `boolean`* functions [#91](https://github.com/dartclub/turf_dart/pull/91)
- Implements `area` function [#123](https://github.com/dartclub/turf_dart/pull/123)
- Implements `polygonSmooth` function [#127](https://github.com/dartclub/turf_dart/pull/127)
- Fixes missing parameter in nearest point on line [#145](https://github.com/dartclub/turf_dart/pull/145)
- Other core improvements
- Support for Dart 3

## 0.0.7

- Implements `nearestPointOn(Multi)Line` [#87](https://github.com/dartclub/turf_dart/pull/87)
- Implements `explode` function [#93](https://github.com/dartclub/turf_dart/pull/93)
- Implements `bbox-polygon` and `bbox`, `center`, polyline functions [#99](https://github.com/dartclub/turf_dart/pull/99)
- Updates the `BBox`-class constructor [#100](https://github.com/dartclub/turf_dart/pull/100)
- Implements `rhumbBearing` function [#109](https://github.com/dartclub/turf_dart/pull/109)
- Implements `lineToPolygon` and `polygonToLine` functions [#104](https://github.com/dartclub/turf_dart/pull/104)
- Implements `truncate` function [#111](https://github.com/dartclub/turf_dart/pull/111)
- Implements `cleanCoord` function [#112](https://github.com/dartclub/turf_dart/pull/112)
- Some documentation & README improvements

## 0.0.6+3

- Rename examples file

## 0.0.6+2

- Added code examples
- Fixed segment * callbacks

## 0.0.6

- This is solely a quality release, without new functionality:
- Documentation: improves pub.dev scores, raised documentation coverage, fixed typos
- Return type fixes for the the meta extensions

## 0.0.5


- Implements *all* meta functions and `lineSegment`
- Adds a lot of documentation
- Several bug and type fixes

## 0.0.4

- Implements the `featureEach` and `propEach` meta function. [#24](https://github.com/dartclub/turf_dart/pull/24)
- PR [#43](https://github.com/dartclub/turf_dart/pull/43):
  - Several bugfixes with the deserialization of JSON
  - Several new constructors
  - Vector arithmetics operations

## 0.0.3

- Null-safety support

## 0.0.2+3

Implements the `geomEach` meta function. [#13](https://github.com/dartclub/turf_dart/pull/13)

## 0.0.2+1

- initialize lists and maps empty in constructors, if not provided

## 0.0.2

- normalization for coordinates (Position)
- and yes, it's still under heavy development

## 0.0.1

- Initial version, still under heavy development
