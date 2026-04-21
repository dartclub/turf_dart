import 'package:turf/turf.dart';

Feature<Point> centerOfMass(
  GeoJSONObject geoJson, {
  Map<String, dynamic>? properties = const {},
}) {
  GeometryObject? geometry;

  if (geoJson is Feature) {
    geometry = geoJson.geometry;
  } else if (geoJson is GeometryObject) {
    geometry = geoJson;
  } else {
    return centroid(geoJson);
  }

  if (geometry is Point) {
    return Feature<Point>(
      geometry: Point(coordinates: geometry.coordinates),
      properties: properties,
    );
  }

  if (geometry is LineString) {
    // line center = average of vertices
    final coords = geometry.coordinates;
    final n = coords.length;
    double sx = 0, sy = 0;
    for (final p in coords) {
      sx += p.lng;
      sy += p.lat;
    }
    return Feature<Point>(
      geometry: Point(coordinates: Position(sx / n, sy / n)),
      properties: properties,
    );
  }

  if (geometry is Polygon) {
    return _centerOfMassPolygon(geometry, properties: properties);
  }

  if (geometry is MultiPolygon) {
    double totalArea = 0.0;
    double sx = 0.0;
    double sy = 0.0;

    for (final polygonCoords in geometry.coordinates) {
      final poly = Polygon(coordinates: polygonCoords);
      final comFeature = _centerOfMassPolygon(poly, properties: properties);
      final com = comFeature.geometry!.coordinates;

      // Compute polygon area
      final area = _polygonArea(polygonCoords.first);
      totalArea += area;

      sx += com.lng * area;
      sy += com.lat * area;
    }

    if (totalArea == 0) {
      // all polygons degenerate -> average of all vertices
      final allVerts = geometry.coordinates.expand((p) => p.first).toList();
      final n = allVerts.length;
      double ax = 0, ay = 0;
      for (final v in allVerts) {
        ax += v.lng;
        ay += v.lat;
      }
      return Feature<Point>(
        geometry: Point(coordinates: Position(ax / n, ay / n)),
        properties: properties,
      );
    }

    final center = Position(sx / totalArea, sy / totalArea);
    return Feature<Point>(
      geometry: Point(coordinates: center),
      properties: properties,
    );
  }

  // fallback
  return centroid(geoJson);
}

/// Computes center of mass for a single Polygon
Feature<Point> _centerOfMassPolygon(
  Polygon polygon, {
  Map<String, dynamic>? properties = const {},
}) {
  final coords = polygon.coordinates.first;
  double sx = 0.0;
  double sy = 0.0;
  double sArea = 0.0;

  for (int i = 0; i < coords.length - 1; i++) {
    final p1 = coords[i];
    final p2 = coords[i + 1];

    final xi = p1.lng.toDouble();
    final yi = p1.lat.toDouble();
    final xj = p2.lng.toDouble();
    final yj = p2.lat.toDouble();

    final a = xi * yj - xj * yi;
    sArea += a;
    sx += (xi + xj) * a;
    sy += (yi + yj) * a;
  }

  final area = sArea / 2;

  if (area == 0) {
    // degenerate -> average of vertices
    double ax = 0.0;
    double ay = 0.0;
    final n = coords.length - 1;
    for (int i = 0; i < n; i++) {
      ax += coords[i].lng;
      ay += coords[i].lat;
    }
    return Feature<Point>(
      geometry: Point(coordinates: Position(ax / n, ay / n)),
      properties: properties,
    );
  }

  final factor = 1 / (6 * area);
  final center = Position(sx * factor, sy * factor);

  return Feature<Point>(
    geometry: Point(coordinates: center),
    properties: properties,
  );
}

/// Computes the signed area of a polygon (Position list)
double _polygonArea(List<Position> coords) {
  double area = 0;
  for (int i = 0; i < coords.length - 1; i++) {
    final xi = coords[i].lng.toDouble();
    final yi = coords[i].lat.toDouble();
    final xj = coords[i + 1].lng.toDouble();
    final yj = coords[i + 1].lat.toDouble();
    area += xi * yj - xj * yi;
  }
  return area.abs() / 2;
}
