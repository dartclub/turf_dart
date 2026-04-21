import 'package:turf/helpers.dart';

import 'package:turf/bbox.dart';
import 'package:turf/bbox_polygon.dart';

/// Returns a rectangular Polygon (envelope) that fully contains the given GeoJSON object.
Feature<Polygon> envelope(GeoJSONObject geojson) {
  return bboxPolygon(bbox(geojson));
}
