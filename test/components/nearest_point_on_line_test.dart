import 'package:test/test.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/nearest_point_on_line.dart';

main() {
  test('nearest_point_on_line -- start point', () {
    final start = Point(coordinates: Position.of([-122.457175, 37.720033]));
    final end = Point(coordinates: Position.of([-122.457175, 37.718242]));

    final line = LineString.fromPoints(points: [start, end]);

    final snapped = nearestPointOnLine(line, start);

    expect(snapped.geometry, start);
    expect(snapped.properties!['dist'], 0);
  });

  test('nearest_point_on_line -- end point', () {
    final start = Point(coordinates: Position.of([-122.457175, 37.720033]));
    final end = Point(coordinates: Position.of([-122.457175, 37.718242]));

    final line = LineString.fromPoints(points: [start, end]);

    final snapped = nearestPointOnLine(line, end);

    expect(snapped.geometry, end);
    expect(snapped.properties!['dist'], 0);
  });

  test('nearest_point_on_line -- behind start point', () {
    final start = Point(coordinates: Position.of([-122.457175, 37.720033]));
    final end = Point(coordinates: Position.of([-122.457175, 37.718242]));

    final line = LineString.fromPoints(points: [start, end]);

    final points = [
      Point(coordinates: Position.of([-122.457175, 37.720093])),
      Point(coordinates: Position.of([-122.457175, 37.820093])),
      Point(coordinates: Position.of([-122.457165, 37.720093])),
      Point(coordinates: Position.of([-122.455165, 37.720093])),
    ];

    for (final point in points) {
      expect(nearestPointOnLine(line, point).geometry, start);
    }
  });

  test('nearest_point_on_line -- in front of last point', () {
    final start = Point(coordinates: Position.of([-122.456161, 37.721259]));
    final middle = Point(coordinates: Position.of([-122.457175, 37.720033]));
    final end = Point(coordinates: Position.of([-122.457175, 37.718242]));

    final line = LineString.fromPoints(points: [start, middle, end]);

    final points = [
      Point(coordinates: Position.of([-122.45696, 37.71814])),
      Point(coordinates: Position.of([-122.457363, 37.718132])),
      Point(coordinates: Position.of([-122.457309, 37.717979])),
      Point(coordinates: Position.of([-122.45718, 37.717045])),
    ];

    for (final point in points) {
      expect(nearestPointOnLine(line, point).geometry, end);
    }
  });

  test('nearest_point_on_line -- on joints', () {
    final lines = [
      LineString.fromPoints(
        points: [
          Point(coordinates: Position.of([-122.456161, 37.721259])),
          Point(coordinates: Position.of([-122.457175, 37.720033])),
          Point(coordinates: Position.of([-122.457175, 37.718242])),
        ],
      ),
      LineString.fromPoints(
        points: [
          Point(coordinates: Position.of([26.279296, 31.728167])),
          Point(coordinates: Position.of([21.796875, 32.694865])),
          Point(coordinates: Position.of([18.808593, 29.993002])),
          Point(coordinates: Position.of([12.919921, 33.137551])),
          Point(coordinates: Position.of([10.195312, 35.603718])),
          Point(coordinates: Position.of([4.921875, 36.527294])),
          Point(coordinates: Position.of([-1.669921, 36.527294])),
          Point(coordinates: Position.of([-5.449218, 34.741612])),
          Point(coordinates: Position.of([-8.789062, 32.990235])),
        ],
      ),
      LineString.fromPoints(
        points: [
          Point(coordinates: Position.of([-0.109198, 51.522042])),
          Point(coordinates: Position.of([-0.10923, 51.521942])),
          Point(coordinates: Position.of([-0.109165, 51.521862])),
          Point(coordinates: Position.of([-0.109047, 51.521775])),
          Point(coordinates: Position.of([-0.108865, 51.521601])),
          Point(coordinates: Position.of([-0.108747, 51.521381])),
          Point(coordinates: Position.of([-0.108554, 51.520687])),
          Point(coordinates: Position.of([-0.108436, 51.520279])),
          Point(coordinates: Position.of([-0.108393, 51.519952])),
          Point(coordinates: Position.of([-0.108178, 51.519578])),
          Point(coordinates: Position.of([-0.108146, 51.519285])),
          Point(coordinates: Position.of([-0.107899, 51.518624])),
          Point(coordinates: Position.of([-0.107599, 51.517782])),
        ],
      ),
    ];

    for (final line in lines) {
      for (final position in line.coordinates) {
        final point = Point(coordinates: position);

        expect(nearestPointOnLine(line, point).geometry, point);
      }
    }
  });

  test('nearest_point_on_line -- along the line', () {
    final line = LineString.fromPoints(
      points: [
        Point(coordinates: Position.of([-0.109198, 51.522042])),
        Point(coordinates: Position.of([-0.10923, 51.521942])),
        Point(coordinates: Position.of([-0.109165, 51.521862])),
        Point(coordinates: Position.of([-0.109047, 51.521775])),
        Point(coordinates: Position.of([-0.108865, 51.521601])),
        Point(coordinates: Position.of([-0.108747, 51.521381])),
        Point(coordinates: Position.of([-0.108554, 51.520687])),
        Point(coordinates: Position.of([-0.108436, 51.520279])),
        Point(coordinates: Position.of([-0.108393, 51.519952])),
        Point(coordinates: Position.of([-0.108178, 51.519578])),
        Point(coordinates: Position.of([-0.108146, 51.519285])),
        Point(coordinates: Position.of([-0.107899, 51.518624])),
        Point(coordinates: Position.of([-0.107599, 51.517782])),
      ],
    );

    final points = [
      Point(
        coordinates: Position.of([-0.109198, 51.522042]),
      ),
      Point(
        coordinates: Position.of([-0.10892694586958439, 51.52166022315509]),
      ),
      Point(
        coordinates: Position.of([-0.10870869056086806, 51.52124324652249]),
      ),
      Point(
        coordinates: Position.of([-0.10858746428471407, 51.520807334251415]),
      ),
      Point(
        coordinates: Position.of([-0.10846283773612979, 51.52037179553692]),
      ),
      Point(
        coordinates: Position.of([-0.10838216818271691, 51.51993315783233]),
      ),
      Point(
        coordinates: Position.of([-0.1081708961571415, 51.51951295576514]),
      ),
      Point(
        coordinates: Position.of([-0.10806814357223703, 51.5190766495002]),
      ),
      Point(
        coordinates: Position.of([-0.10790712893372725, 51.51864575426176]),
      ),
      Point(
        coordinates: Position.of([-0.10775288313545159, 51.518213902651325]),
      ),
    ];

    for (final point in points) {
      final snapped = nearestPointOnLine(line, point);
      final shift = distance(point, snapped.geometry!, Unit.centimeters);

      expect(shift < 1, isTrue);
    }
  });

  test('nearest_point_on_line -- on sides of line', () {
    final start = Point(coordinates: Position.of([-122.456161, 37.721259]));
    final end = Point(coordinates: Position.of([-122.457175, 37.718242]));

    final line = LineString.fromPoints(points: [start, end]);

    final points = [
      Point(coordinates: Position.of([-122.457025, 37.71881])),
      Point(coordinates: Position.of([-122.457336, 37.719235])),
      Point(coordinates: Position.of([-122.456864, 37.72027])),
      Point(coordinates: Position.of([-122.45652, 37.720635])),
    ];

    for (final point in points) {
      final snapped = nearestPointOnLine(line, point);

      expect(snapped.geometry, isNot(start));
      expect(snapped.geometry, isNot(end));
    }
  });

  test('nearest_point_on_line -- distance and index', () {
    final line = LineString.fromPoints(
      points: [
        Point(coordinates: Position.of([-92.090492, 41.102897])),
        Point(coordinates: Position.of([-92.191085, 41.079868])),
        Point(coordinates: Position.of([-92.228507, 41.056055])),
        Point(coordinates: Position.of([-92.237091, 41.008143])),
        Point(coordinates: Position.of([-92.225761, 40.966937])),
        Point(coordinates: Position.of([-92.15023, 40.936858])),
        Point(coordinates: Position.of([-92.112464, 40.977565])),
        Point(coordinates: Position.of([-92.062683, 41.034564])),
        Point(coordinates: Position.of([-92.100791, 41.040002])),
      ],
    );

    final point = Point(coordinates: Position.of([-92.110576, 41.040649]));
    final target = Point(coordinates: Position.of([-92.100791, 41.040002]));

    final snapped = nearestPointOnLine(line, point);

    expect(snapped.geometry, target);

    final index = snapped.properties!['index'] as int;
    final distance = snapped.properties!['dist'] as num;

    expect(index, 8);
    expect(distance.toStringAsFixed(6), '0.823802');
  });

  test('nearest_point_on_line -- empty multi-line', () {
    final multiLine = MultiLineString(coordinates: []);

    final point = Point(coordinates: Position.of([-92.110576, 41.040649]));

    final snapped = nearestPointOnMultiLine(multiLine, point);

    expect(snapped, isNull);
  });

  test('nearest_point_on_line -- distance, line, and index', () {
    final multiLine = MultiLineString.fromLineStrings(
      lineStrings: [
        LineString.fromPoints(
          points: [
            Point(coordinates: Position.of([-92.090492, 41.102897])),
            Point(coordinates: Position.of([-92.191085, 41.079868])),
            Point(coordinates: Position.of([-92.228507, 41.056055])),
            Point(coordinates: Position.of([-92.237091, 41.008143])),
            Point(coordinates: Position.of([-92.225761, 40.966937])),
            Point(coordinates: Position.of([-92.15023, 40.936858])),
            Point(coordinates: Position.of([-92.112464, 40.977565])),
            Point(coordinates: Position.of([-92.062683, 41.034564])),
            Point(coordinates: Position.of([-92.100791, 41.040002])),
          ],
        ),
        LineString.fromPoints(
          points: [
            Point(coordinates: Position.of([-92.141304, 41.124107])),
            Point(coordinates: Position.of([-92.020797, 41.108329])),
            Point(coordinates: Position.of([-91.973762, 41.019023])),
            Point(coordinates: Position.of([-92.041740, 40.944120])),
            Point(coordinates: Position.of([-92.151260, 40.928299])),
            Point(coordinates: Position.of([-92.198295, 40.941008])),
            Point(coordinates: Position.of([-92.199668, 41.012547])),
            Point(coordinates: Position.of([-92.115413, 41.041633])),
            Point(coordinates: Position.of([-92.143020, 41.076504])),
          ],
        ),
        LineString.fromPoints(
          points: [
            Point(coordinates: Position.of([-92.066116, 41.079092])),
            Point(coordinates: Position.of([-92.028007, 41.045957])),
            Point(coordinates: Position.of([-92.040023, 40.981453])),
            Point(coordinates: Position.of([-92.114181, 40.951640])),
            Point(coordinates: Position.of([-92.176666, 40.968752])),
            Point(coordinates: Position.of([-92.210655, 40.997002])),
            Point(coordinates: Position.of([-92.209968, 41.048547])),
            Point(coordinates: Position.of([-92.158126, 41.071327])),
            Point(coordinates: Position.of([-92.102508, 41.082197])),
          ],
        ),
      ],
    );

    final point = Point(coordinates: Position.of([-92.110576, 41.040649]));
    final target = Point(coordinates: Position.of([-92.115413, 41.041633]));

    final snapped = nearestPointOnMultiLine(multiLine, point);

    expect(snapped, isNotNull);

    expect(snapped!.geometry, target);

    final line = snapped.properties!['line'] as int;
    final localIndex = snapped.properties!['localIndex'] as int;
    final globalIndex = snapped.properties!['index'] as int;
    final distance = snapped.properties!['dist'] as num;

    expect(line, 1);
    expect(localIndex, 7);
    expect(globalIndex, 16);
    expect(distance.toStringAsFixed(6), '0.420164');
  });
}
