import '../helpers.dart';

import '../bbox.dart';
import '../bbox_polygon.dart';



Feature<Polygon> envelope(GeoJSONObject geojson) {
    return bboxPolygon(bbox(geojson));
}