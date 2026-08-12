
// Deep clone any GeoJSON object: FeatureCollection, Feature, Geometry, and Properties.

dynamic clone(dynamic geojson) {
  if (geojson == null) {
    throw ArgumentError('geojson is required');
  }

  switch (geojson['type']) {
    case 'Feature':
      return cloneFeature(geojson);
    case 'FeatureCollection':
      return cloneFeatureCollection(geojson);
    case 'Point':
    case 'LineString':
    case 'Polygon':
    case 'MultiPoint':
    case 'MultiLineString':
    case 'MultiPolygon':
    case 'GeometryCollection':
      return cloneGeometry(geojson);
    default:
      throw ArgumentError('unknown GeoJSON type');
  }
}

Map<String, dynamic> cloneFeature(Map<String, dynamic> geojson) {
  final cloned = <String, dynamic>{'type': 'Feature'};

  // Preserve foreign members
  geojson.forEach((key, value) {
    if (key != 'type' && key != 'properties' && key != 'geometry') {
      cloned[key] = value;
    }
  });

  cloned['properties'] = cloneProperties(geojson['properties']);
  cloned['geometry'] = geojson['geometry'] == null
      ? null
      : cloneGeometry(geojson['geometry']);

  return cloned;
}

dynamic cloneProperties(dynamic properties) {
  if (properties == null) return {};

  final cloned = <String, dynamic>{};

  (properties as Map<String, dynamic>).forEach((key, value) {
    if (value is Map) {
      cloned[key] = cloneProperties(value);
    } else if (value is List) {
      cloned[key] = List.from(value);
    } else {
      cloned[key] = value;
    }
  });

  return cloned;
}

Map<String, dynamic> cloneFeatureCollection(Map<String, dynamic> geojson) {
  final cloned = <String, dynamic>{'type': 'FeatureCollection'};

  // Preserve foreign members
  geojson.forEach((key, value) {
    if (key != 'type' && key != 'features') {
      cloned[key] = value;
    }
  });

  cloned['features'] =
      (geojson['features'] as List).map((f) => cloneFeature(f)).toList();

  return cloned;
}

Map<String, dynamic> cloneGeometry(Map<String, dynamic> geometry) {
  final geom = <String, dynamic>{'type': geometry['type']};

  if (geometry.containsKey('bbox')) {
    geom['bbox'] = List.from(geometry['bbox']);
  }

  if (geometry['type'] == 'GeometryCollection') {
    geom['geometries'] = (geometry['geometries'] as List)
        .map((g) => cloneGeometry(g))
        .toList();
  } else {
    geom['coordinates'] = deepSlice(geometry['coordinates']);
  }

  return geom;
}

dynamic deepSlice(dynamic coords) {
  if (coords is List) {
    if (coords.isEmpty || coords[0] is! List) {
      return List.from(coords);
    } else {
      return coords.map((c) => deepSlice(c)).toList();
    }
  }
  return coords;
}
