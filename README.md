# turf.dart

[![pub package](https://img.shields.io/pub/v/turf.svg)](https://pub.dev/packages/turf)

THIS PROJECT IS WORK IN PROCESS

A [turf.js](https://github.com/Turfjs/turf)-like geospatial analysis library working with GeoJSON, written in pure Dart.

This includes a fully [RFC 7946](https://tools.ietf.org/html/rfc7946)-compliant object-representation and serialization for GeoJSON.

Most of the implementation is a direct translation from [turf.js](https://github.com/Turfjs/turf).

## Get started
- Get the [Dart tools](https://dart.dev/tools)
- Install the library with `dart pub add turf`
- Import the library in your code and use it. For example:
```dart
import 'package:turf/helpers.dart';
import 'package:turf/src/line_segment.dart';

Feature<Polygon> poly = Feature<Polygon>(
  geometry: Polygon(coordinates: [
    [
      Position(0, 0),
      Position(2, 2),
      Position(0, 1),
      Position(0, 0),
    ],
    [
      Position(0, 0),
      Position(1, 1),
      Position(0, 1),
      Position(0, 0),
    ],
  ]),
);

main() {
  var total = segmentReduce<int>(
    poly,
    (previousValue, currentSegment, initialValue, featureIndex,
        multiFeatureIndex, geometryIndex, segmentIndex) {
      if (previousValue != null) {
        previousValue++;
      }
      return previousValue;
    },
    0,
    combineNestedGeometries: false,
  );
  print(total);
  // total ==  6
}
```

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
- [x] clone - implemented as a member function of each [GeoJSONObject]
- [ ] concave
- [ ] convex
- [ ] difference
- [ ] dissolve
- [ ] intersect
- [ ] lineOffset
- [ ] polygonSmooth
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
- [x] [explode](https://github.com/dartclub/turf_dart/blob/main/lib/src/explode.dart)
- [ ] flatten
- [ ] lineToPolygon
- [ ] polygonize
- [ ] polygonToLine

### MISC
- [ ] ellipse
- [ ] kinks
- [ ] lineArc
- [ ] lineChunk
- [ ] lineIntersect
- [ ] lineOverlap
- [x] [lineSegment](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_segment.dart)
- [ ] lineSlice
- [ ] lineSliceAlong
- [ ] lineSplit
- [ ] mask
- [x] [nearestPointOnLine](https://github.com/dartclub/turf_dart/blob/master/lib/nearest_point_on_line.dart)
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
- [x] [coordAll](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/coord.dart)
- [x] [coordEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/coord.dart)
- [x] [coordReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/coord.dart)
- [x] [featureEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/feature.dart)
- [x] [featureReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/feature.dart)
- [x] [flattenEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/flatten.dart)
- [x] [flattenReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/flatten.dart)
- [x] [getCoord](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/coord.dart)
- [x] [getCoords](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/coord.dart)
- [x] [geomEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/geom.dart)
- [x] [geomReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/geom.dart)
- [x] [propEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/prop.dart)
- [x] [propReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/prop.dart)
- [x] [segmentEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_segment.dart)
- [x] [segmentReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_segment.dart)
- [x] [getCluster](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/cluster.dart)
- [x] [clusterEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/cluster.dart)
- [x] [clusterReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/cluster.dart)

### Booleans
- [ ] booleanClockwise
- [ ] booleanConcave
- [ ] booleanContains
- [ ] booleanCrosses
- [ ] booleanDisjoint
- [ ] booleanEqual
- [ ] booleanIntersects
- [ ] booleanOverlap
- [ ] booleanParallel
- [ ] booleanPointInPolygon
- [ ] booleanPointOnLine
- [ ] booleanWithin

### Unit Conversion
- [x] [bearingToAzimuth](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [x] [convertArea](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [x] [convertLength](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [x] [degreesToRadians](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [x] [lengthToRadians](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [x] [lengthToDegrees](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [x] [radiansToLength](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [x] [radiansToDegrees](https://github.com/dartclub/turf_dart/blob/main/lib/src/helpers.dart)
- [ ] toMercator
- [ ] toWgs84
