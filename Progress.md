
## Progress
This document tracks the progress being made to port over all of the Turf functionality to 
Dart. This is an on going project and functions are being added once needed. If you'd like to contribute by adding a Turf function that's missing, please open a GitHub issue still with information relative to why you need this functionality.

### Measurement

- [x] [along](https://github.com/dartclub/turf_dart/blob/main/lib/src/along.dart)
- [x] [area](https://github.com/dartclub/turf_dart/blob/main/lib/src/area.dart)
- [x] [bbox](https://github.com/dartclub/turf_dart/blob/main/lib/src/bbox.dart)
- [x] [bboxPolygon](https://github.com/dartclub/turf_dart/blob/main/lib/src/bbox_polygon.dart)
- [x] [bearing](https://github.com/dartclub/turf_dart/blob/main/lib/src/bearing.dart)
- [x] [center](https://github.com/Dennis-Mwea/turf_dart/blob/main/lib/src/center.dart)
- [ ] centerOfMass
- [x] [centroid](https://github.com/dartclub/turf_dart/blob/main/lib/src/centroid.dart)
- [x] [destination](https://github.com/dartclub/turf_dart/blob/main/lib/src/destination.dart)
- [x] [distance](https://github.com/dartclub/turf_dart/blob/main/lib/src/distance.dart)
- [ ] envelope
- [x] [length](https://github.com/dartclub/turf_dart/blob/main/lib/src/length.dart)
- [x] [midpoint](https://github.com/dartclub/turf_dart/blob/main/lib/src/midpoint.dart)
- [ ] pointOnFeature
- [ ] polygonTangents
- [x] [pointToLineDistance](https://github.com/dartclub/turf_dart/blob/main/lib/src/point_to_line_distance.dart)
- [x] [rhumbBearing](https://github.com/dartclub/turf_dart/blob/main/lib/src/rhumb_bearing.dart)
- [x] [rhumbDestination](https://github.com/dartclub/turf_dart/blob/main/lib/src/rhumb_destination.dart)
- [x] [rhumbDistance](https://github.com/dartclub/turf_dart/blob/main/lib/src/rhumb_distance.dart)
- [ ] square
- [ ] greatCircle

### Coordinate Mutation

- [x] [cleanCoords](https://github.com/dartclub/turf_dart/blob/main/lib/src/clean_coords.dart)
- [ ] flip
- [ ] rewind
- [ ] round
- [x] [truncate](https://github.com/dartclub/turf_dart/blob/main/lib/src/truncate.dart)

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
- [x] [polygonSmooth](https://github.com/dartclub/turf_dart/blob/main/lib/src/polygon_smooth.dart)
- [x] [simplify](https://github.com/dartclub/turf_dart/blob/main/lib/src/simplify.dart)
- [ ] tesselate
- [x] [transformRotate](https://github.com/dartclub/turf_dart/blob/main/lib/src/transform_rotate.dart)
- [ ] transformTranslate
- [ ] transformScale
- [ ] union
- [ ] voronoi
- [x] [polyLineDecode](https://github.com/dartclub/turf_dart/blob/main/lib/src/polyline.dart)

### Feature Conversion

- [ ] combine
- [x] [explode](https://github.com/dartclub/turf_dart/blob/main/lib/src/explode.dart)
- [ ] flatten
- [x] [lineToPolygon](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_to_polygon.dart)
- [ ] polygonize
- [x] [polygonToLine](https://github.com/dartclub/turf_dart/blob/main/lib/src/polygon_to_line.dart)

### MISC

- [ ] ellipse
- [ ] kinks
- [ ] lineArc
- [ ] lineChunk
- [ ] [lineIntersect](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_intersect.dart)
- [x] [lineOverlap](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_overlap.dart)
- [x] [lineSegment](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_segment.dart)
- [x] [lineSlice](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_slice.dart)
- [ ] lineSliceAlong
- [ ] lineSplit
- [ ] mask
- [x] [nearestPointOnLine](https://github.com/dartclub/turf_dart/blob/main/lib/src/nearest_point_on_line.dart)
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

- [x] [nearestPoint](https://github.com/dartclub/turf_dart/blob/main/lib/src/nearest_point.dart)

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
- [x] [geomEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/geom.dart)
- [x] [geomReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/geom.dart)
- [x] [propEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/prop.dart)
- [x] [propReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/prop.dart)
- [x] [segmentEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_segment.dart)
- [x] [segmentReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/line_segment.dart)
- [x] [getCluster](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/cluster.dart)
- [x] [clusterEach](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/cluster.dart)
- [x] [clusterReduce](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/cluster.dart)

### Invariants

- [x] [getCoord](https://github.com/dartclub/turf_dart/blob/main/lib/src/meta/coord.dart)
- [x] [getCoords](https://github.com/dartclub/turf_dart/blob/main/lib/src/invariant.dart)
- [x] [getGeom](https://github.com/dartclub/turf_dart/blob/main/lib/src/invariant.dart)

### Booleans

- [x] [booleanClockwise](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_clockwise.dart)
- [x] [booleanConcave](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_concave.dart)
- [x] [booleanContains](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_contains.dart)
- [x] [booleanCrosses](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_crosses.dart)
- [x] [booleanDisjoint](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_disjoint.dart)
- [x] [booleanEqual](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_equal.dart)
- [x] [booleanIntersects](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_intersects.dart)
- [x] [booleanOverlap](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_overlap.dart)
- [x] [booleanParallel](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_parallel.dart)
- [x] [booleanPointInPolygon](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_point_in_polygon.dart)
- [x] [booleanPointOnLine](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_point_on_line.dart)
- [x] [booleanWithin](https://github.com/dartclub/turf_dart/blob/main/lib/src/booleans/boolean_within.dart)

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