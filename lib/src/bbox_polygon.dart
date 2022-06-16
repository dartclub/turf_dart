import '../helpers.dart';

/// Takes a bbox and returns an equivalent [Feature<Polygon>].
/// ```dart
/// var bbox = Bbox(0, 0, 10, 10);
/// var poly = bboxPolygon(bbox);
/// //addToMap
/// var addToMap = [poly]
/// ```
Feature<Polygon> bboxPolygon(BBox bbox,
    {Map<String, dynamic> properties = const {}, dynamic id}) {
  var west = bbox[0]!;
  var south = bbox[1]!;
  var east = bbox[2]!;
  var north = bbox[3]!;

  if (bbox.length == 6) {
    throw Exception(
        "@turf/bbox-polygon does not support BBox with 6 positions");
  }

  var lowLeft = [west, south];
  var topLeft = [west, north];
  var topRight = [east, north];
  var lowRight = [east, south];

  return Feature(
    properties: properties,
    id: id,
    geometry: Polygon(
      coordinates: [
        [
          Position.of(lowLeft),
          Position.of(lowRight),
          Position.of(topRight),
          Position.of(topLeft),
          Position.of(lowLeft)
        ]
      ],
    ),
  );
}
