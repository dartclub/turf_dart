# TurfDart
[![pub package](https://img.shields.io/pub/v/turf.svg)](https://pub.dev/packages/turf)

A [TurfJs](https://github.com/Turfjs/turf)-like geospatial analysis library written in pure Dart.

TurfDart is a Dart library for [spatial analysis](https://en.wikipedia.org/wiki/Spatial_analysis). It includes traditional spatial operations, helper functions for creating GeoJSON data, and data classification and statistics tools. You can use TurfDart in your Flutter applications on the web, mobile and desktop or in pure Dart applications running on the server.

As the foundation, we are using [Geotypes](https://github.com/dartclub/geotypes), a lightweight dart library that provides a strong object model for GeoJson and implements a fully [RFC 7946](https://tools.ietf.org/html/rfc7946) compliant GeoJSON serialization.

Most of the functionality is a direct translation from [turf.js](https://github.com/Turfjs/turf).

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

void main() {
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

### Notable Design Decisions

- Nested `GeometryCollections` (as described in
  [RFC 7946 section 3.1.8](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.8))
  are _not supported_ which takes a slightly firmer stance than the "should
  avoid" language in the specification

## Tests and Benchmarks

Tests are run with `dart test` and benchmarks can be run with
`dart run benchmark`

Any new benchmarks must be named `*_benchmark.dart` and reside in the
`./benchmark` folder.
