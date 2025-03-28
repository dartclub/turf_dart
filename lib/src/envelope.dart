import '../helpers.dart';

import '../bbox.dart';
import '../bbox_polygon.dart';



num? envelope(GeoJSONObject geojson) {
    return bboxPolygon(bbox(geojson));
}