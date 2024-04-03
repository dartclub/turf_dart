<h1 align="center">
  <br>
  <img src="https://github.com/dartclub/turf_dart/blob/main/.github/turf-logo.png" alt="TurfDart Logo" width="250">
</h1>

<h4 align="center">A <a href="https://github.com/Turfjs/turf">TurfJs</a>-like geospatial analysis library written in pure Dart.
</h4>
<br>

[![pub package](https://img.shields.io/pub/v/turf.svg)](https://pub.dev/packages/turf)
![dart unit tests](https://github.com/dartclub/turf_dart/actions/workflows/dart-unit-tests.yml/badge.svg)
![dart publish](https://github.com/dartclub/turf_dart/actions/workflows/dart-pub-publish.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

<h3>–> [Join our Dart / Flutter GIS Community on Discord](https://discord.gg/cTJk98cU) <–</h3>

TurfDart is a Dart library for [spatial analysis](https://en.wikipedia.org/wiki/Spatial_analysis). It includes traditional spatial operations, helper functions for creating GeoJSON data, and data classification and statistics tools. You can use TurfDart in your Flutter applications on the web, mobile and desktop or in pure Dart applications running on the server.

As the foundation, we are using [Geotypes](https://github.com/dartclub/geotypes), a lightweight dart library that provides a strong GeoJSON object model and fully [RFC 7946](https://tools.ietf.org/html/rfc7946) compliant serializers.

Most of the functionality is a translation from [turf.js](https://github.com/Turfjs/turf), the progress can be found [here](Progress.md).

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
