import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/point_to_line_distance.dart';

final distances = {
  "city-line1.geojson": 1.0299686758,
  "city-line2.geojson": 3.6186172981,
  "city-segment-inside1.geojson": 1.1489389115,
  "city-segment-inside2.geojson": 1.0280898152,
  "city-segment-inside3.geojson": 3.5335695907,
  "city-segment-obtuse1.geojson": 2.8573246363,
  "city-segment-obtuse2.geojson": 3.3538913334,
  "city-segment-projected1.geojson": 3.5886611693,
  "city-segment-projected2.geojson": 4.163469898,
  "issue-1156.geojson": 189.6618028794,
  "line-fiji.geojson": 27.1266612008,
  "line-resolute-bay.geojson": 425.0745081528,
  "line1.geojson": 23.4224834672,
  "line2.geojson": 188.015686924,
  "segment-fiji.geojson": 27.6668301762,
  "segment1.geojson": 69.0934195756,
  "segment1a.geojson": 69.0934195756,
  "segment2.geojson": 69.0934195756,
  "segment3.geojson": 69.0828960461,
  "segment4.geojson": 332.8803863574
};

void main() {
  group('pointToLineDistance', () {
    group('in == out', () {
      final inDir = Directory('./test/examples/point_to_line_distance/in');

      for (final file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          testFile(file);
        }
      }
    });

    group('unit tests', () {
      testPlanarGeodesic();
    });
  });
}

void testFile(File file) {
  test(file.path, () {
    final inSource = file.readAsStringSync();
    final collection = FeatureCollection.fromJson(jsonDecode(inSource));

    final rawPoint = collection.features[0];
    final rawLine = collection.features[1];

    final point = Feature<Point>.fromJson(rawPoint.toJson());
    final line = Feature<LineString>.fromJson(rawLine.toJson());

    final properties = rawPoint.properties ?? {};
    final unitRaw = properties["units"] as String?;

    var unit = Unit.kilometers;
    if (unitRaw == 'meters') {
      unit = Unit.meters;
    } else if (unitRaw == 'miles') {
      unit = Unit.miles;
    } else {
      expect(unitRaw, null, reason: '"units" was given but not handled.');
    }

    final distance =
        pointToLineDistance(point.geometry!, line.geometry!, unit: unit);

    final name = file.path.substring(file.path.lastIndexOf('/') + 1);

    expect(distance, closeTo(distances[name]!, 0.01));
  });
}

void testPlanarGeodesic() {
  test('Check planar and geodesic results are different', () {
    final pt = Point(coordinates: Position(0, 0));
    final line = LineString(coordinates: [
      Position(10, 10),
      Position(-1, 1),
    ]);

    final geoOut =
        pointToLineDistance(pt, line, method: DistanceGeometry.geodesic);
    final planarOut =
        pointToLineDistance(pt, line, method: DistanceGeometry.planar);

    expect(geoOut, isNot(equals(planarOut)));
  });
}
