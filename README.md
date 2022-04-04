# turf.dart

[![pub package](https://img.shields.io/pub/v/turf.svg)](https://pub.dev/packages/turf)

THIS PROJECT IS WORK IN PROCESS

A [turf.js](https://github.com/Turfjs/turf)-like geospatial analysis library working with GeoJSON, written in pure Dart.

This includes a fully [RFC 7946](https://tools.ietf.org/html/rfc7946)-compliant object-representation and serialization for GeoJSON.

Most of the implementation is a direct translation from [turf.js](https://github.com/Turfjs/turf).

## GeoJSON Object Model

![polymorphism](https://user-images.githubusercontent.com/10634693/159876354-f9da2f37-02b3-4546-b32a-c0f82c372272.png)

## Notable Design Decisions
- Nested `GeometryCollections` (as described in
  [RFC 7946 section 3.1.8](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.8))
  are _not supported_ which takes a slightly firmer stance than the "should
  avoid" language in the specification

## Tests and Benchmarks
Tests are run with `dart test` and benchmarks can be run with
`dart run benchmark`

Any new benchmarks must be named `*_benchmark.dart` and reside in the
`./benchmark` folder.

## Components

### Measurement
- [ ] along
- [ ] area
- [x] [bbox](https://github.com/Dennis-Mwea/turf_dart/blob/main/lib/src/bbox.dart)
- [ ] bboxPolygon
- [x] [bearing](https://github.com/dartclub/turf_dart/blob/main/lib/bearing.dart)
- [ ] [center](https://github.com/Dennis-Mwea/turf_dart/blob/main/lib/src/center.dart)
- [ ] centerOfMass
- [ ] centroid
- [x] [destination](https://github.com/dartclub/turf_dart/blob/main/lib/destination.dart)
- [x] [distance](https://github.com/dartclub/turf_dart/blob/main/lib/distance.dart)
- [ ] envelope
- [ ] length
- [x] [midpoint](https://github.com/dartclub/turf_dart/blob/main/lib/midpoint.dart)
- [ ] pointOnFeature
- [ ] polygonTangents
- [ ] pointToLineDistance
- [ ] rhumbBearing
- [ ] rhumbDestination
- [ ] rhumbDistance
- [ ] square
- [ ] greatCircle

### Coordinate Mutation
- [ ] cleanCoords
- [ ] flip
- [ ] rewind
- [ ] round
- [ ] truncate

### Transformation
- [ ] bboxClip
- [ ] bezierSpline
- [ ] buffer
- [ ] circle
- [ ] clone
- [ ] concave
- [ ] convex
- [ ] difference
- [ ] dissolve
- [ ] intersect
- [ ] lineOffset
- [ ] simplify
- [ ] tesselate
- [ ] transformRotate
- [ ] transformTranslate
- [ ] transformScale
- [ ] union
- [ ] voronoi
- [x] [polyLineDecode](https://github.com/Dennis-Mwea/turf_dart/blob/main/lib/src/polyline.dart)

### Feature Conversion
- [ ] combine
- [ ] explode
- [ ] flatten
- [ ] lineToPolygon
- [ ] polygonize
- [ ] polygonToLine

### MISC
- [ ] kinks
- [ ] lineArc
- [ ] lineChunk
- [ ] lineIntersect
- [ ] lineOverlap
- [x] lineSegment
- [ ] lineSlice
- [ ] lineSliceAlong
- [ ] lineSplit
- [ ] mask
- [ ] nearestPointOnLine
- [ ] sector
- [ ] shortestPath
- [ ] unkinkPolygon

### Random
- [ ] randomPosition
- [ ] randomPoint
- [ ] randomLineString
- [ ] randomPolygon

### Data
- [ ] sample

### Interpolation
- [ ] interpolate
- [ ] isobands
- [ ] isolines
- [ ] planepoint
- [ ] tin

### Joins
- [ ] pointsWithinPolygon
- [ ] tag

### Grids
- [ ] hexGrid
- [ ] pointGrid
- [ ] squareGrid
- [ ] triangleGrid

### Classification
- [x] [nearestPoint](https://github.com/dartclub/turf_dart/blob/main/lib/nearest_point.dart)

### Aggregation
- [ ] collect
- [ ] clustersDbscan
- [ ] clustersKmeans

### META
- [x] coordAll
- [x] coordEach
- [x] coordReduce
- [x] [featureEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta.dart#L157)
- [x] featureReduce
- [x] [flattenEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta.dart#L181)
- [x] flattenReduce
- [x] getCoord
- [x] getCoords
- [x] [geomEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta.dart#L34)
- [x] geomReduce
- [x] [propEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta.dart#L124)
- [x] propReduce
- [x] segmentEach
- [x] segmentReduce
- [ ] getCluster
- [ ] clusterEach
- [ ] clusterReduce

### Assertions
- [ ] collectionOf
- [ ] containsNumber
- [ ] geojsonType
- [ ] featureOf

### Booleans
- [ ] booleanClockwise
- [ ] booleanContains
- [ ] booleanCrosses
- [ ] booleanDisjoint
- [ ] booleanEqual
- [ ] booleanOverlap
- [ ] booleanParallel
- [ ] booleanPointInPolygon
- [ ] booleanPointOnLine
- [ ] booleanWithin

### Unit Conversion
- [x] [bearingToAzimuth](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L103)
- [x] [convertArea](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L132)
- [x] [convertLength](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L121)
- [x] [degreesToRadians](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L116)
- [x] [lengthToRadians](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L91)
- [x] [lengthToDegrees](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L99)
- [x] [radiansToLength](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L83)
- [x] [radiansToDegrees](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart#L111)
- [ ] toMercator
- [ ] toWgs84
