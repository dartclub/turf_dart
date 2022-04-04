import 'package:test/test.dart';
import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';

main() {
  test('bbox', () {
    Map<String, dynamic> data = {
      'features': [
        <String, dynamic>{
          'type': "Feature",
          'properties': <String, dynamic>{},
          'geometry': <String, dynamic>{
            'type': "Polygon",
            'coordinates': [
              [
                [-108.8470458984375, 38.238180119798635],
                [-108.2098388671875, 38.238180119798635],
                [-108.2098388671875, 39.317300373271024],
                [-108.8470458984375, 39.317300373271024],
                [-108.8470458984375, 38.238180119798635]
              ]
            ]
          }
        }
      ]
    };
    FeatureCollection feature = FeatureCollection.fromJson(data);

    var bBox = bbox(feature);
    expect(bBox.lng1.toString(), '38.238180119798635');
    expect(bBox.lat1.toString(), '-108.8470458984375');
    expect(bBox.lng2.toString(), '39.317300373271024');
    expect(bBox.lat2.toString(), '-108.2098388671875');
  });
}
