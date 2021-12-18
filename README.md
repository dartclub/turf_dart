# turf.dart

THIS PROJECT IS WORK IN PROCESS

A [turf.js](https://github.com/Turfjs/turf)-like geospatial analysis library working with GeoJSON, written in pure Dart.

This includes a fully [RFC 7946](https://tools.ietf.org/html/rfc7946)-compliant object-representation and serialization for GeoJSON.

Most of the implementation is a direct translation from [turf.js](https://github.com/Turfjs/turf).

## Tests and Benchmarks
Tests are run with `dart test` and benchmarks can be run with
`dart run benchmark`

Any new benchmarks must be named `*_benchmark.dart` and reside in the
`./benchmark` folder.

## Components

### Measurement
- [ ] along
- [ ] area
- [ ] bbox
- [ ] bboxPolygon
- [x] [bearing](https://github.com/dartclub/turf_dart/blob/master/lib/bearing.dart)
- [ ] center
- [ ] centerOfMass
- [ ] centroid
- [x] [destination](https://github.com/dartclub/turf_dart/blob/master/lib/destination.dart)
- [x] [distance](https://github.com/dartclub/turf_dart/blob/master/lib/distance.dart)
- [ ] envelope
- [ ] length
- [x] [midpoint](https://github.com/dartclub/turf_dart/blob/master/lib/midpoint.dart)
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
- [ ] lineSegment
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
- [x] [nearestPoint](https://github.com/dartclub/turf_dart/blob/master/lib/nearest_point.dart)

### Aggregation
- [ ] collect
- [ ] clustersDbscan
- [ ] clustersKmeans

### META
- [ ] coordAll
- [ ] coordEach
- [ ] coordReduce
- [ ] featureEach
- [ ] featureReduce
- [ ] flattenEach
- [ ] flattenReduce
- [ ] getCoord
- [ ] getCoords
- [ ] getGeom
- [ ] getType
- [ ] geomEach
- [ ] geomReduce
- [ ] propEach
- [ ] propReduce
- [ ] segmentEach
- [ ] segmentReduce
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
- [x] [bearingToAzimuth](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L103)
- [x] [convertArea](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L132)
- [x] [convertLength](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L121)
- [x] [degreesToRadians](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L116)
- [x] [lengthToRadians](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L91)
- [x] [lengthToDegrees](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L99)
- [x] [radiansToLength](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L83)
- [x] [radiansToDegrees](https://github.com/dartclub/turf_dart/blob/master/lib/src/helpers.dart#L111)
- [ ] toMercator
- [ ] toWgs84
