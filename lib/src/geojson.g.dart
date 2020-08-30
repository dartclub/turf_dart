// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geojson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Point _$PointFromJson(Map<String, dynamic> json) {
  return Point(
    bbox: json['bbox'] == null
        ? null
        : BBox.fromJson((json['bbox'] as List)?.map((e) => e as num)?.toList()),
    coordinates: json['coordinates'] == null
        ? null
        : Position.fromJson(
            (json['coordinates'] as List)?.map((e) => e as num)?.toList()),
  );
}

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
      'coordinates': instance.coordinates?.toJson(),
      'bbox': instance.bbox?.toJson(),
    };

MultiPoint _$MultiPointFromJson(Map<String, dynamic> json) {
  return MultiPoint(
    bbox: json['bbox'] == null
        ? null
        : BBox.fromJson((json['bbox'] as List)?.map((e) => e as num)?.toList()),
    coordinates: (json['coordinates'] as List)
        ?.map((e) => e == null
            ? null
            : Position.fromJson((e as List)?.map((e) => e as num)?.toList()))
        ?.toList(),
  );
}

Map<String, dynamic> _$MultiPointToJson(MultiPoint instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates?.map((e) => e?.toJson())?.toList(),
      'bbox': instance.bbox?.toJson(),
    };

LineString _$LineStringFromJson(Map<String, dynamic> json) {
  return LineString(
    bbox: json['bbox'] == null
        ? null
        : BBox.fromJson((json['bbox'] as List)?.map((e) => e as num)?.toList()),
    coordinates: (json['coordinates'] as List)
        ?.map((e) => e == null
            ? null
            : Position.fromJson((e as List)?.map((e) => e as num)?.toList()))
        ?.toList(),
  );
}

Map<String, dynamic> _$LineStringToJson(LineString instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates?.map((e) => e?.toJson())?.toList(),
      'bbox': instance.bbox?.toJson(),
    };

MultiLineString _$MultiLineStringFromJson(Map<String, dynamic> json) {
  return MultiLineString(
    bbox: json['bbox'] == null
        ? null
        : BBox.fromJson((json['bbox'] as List)?.map((e) => e as num)?.toList()),
    coordinates: (json['coordinates'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : Position.fromJson(
                    (e as List)?.map((e) => e as num)?.toList()))
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$MultiLineStringToJson(MultiLineString instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates
          ?.map((e) => e?.map((e) => e?.toJson())?.toList())
          ?.toList(),
      'bbox': instance.bbox?.toJson(),
    };

Polygon _$PolygonFromJson(Map<String, dynamic> json) {
  return Polygon(
    bbox: json['bbox'] == null
        ? null
        : BBox.fromJson((json['bbox'] as List)?.map((e) => e as num)?.toList()),
    coordinates: (json['coordinates'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : Position.fromJson(
                    (e as List)?.map((e) => e as num)?.toList()))
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$PolygonToJson(Polygon instance) => <String, dynamic>{
      'coordinates': instance.coordinates
          ?.map((e) => e?.map((e) => e?.toJson())?.toList())
          ?.toList(),
      'bbox': instance.bbox?.toJson(),
    };

MultiPolygon _$MultiPolygonFromJson(Map<String, dynamic> json) {
  return MultiPolygon(
    bbox: json['bbox'] == null
        ? null
        : BBox.fromJson((json['bbox'] as List)?.map((e) => e as num)?.toList()),
    coordinates: (json['coordinates'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => (e as List)
                ?.map((e) => e == null
                    ? null
                    : Position.fromJson(
                        (e as List)?.map((e) => e as num)?.toList()))
                ?.toList())
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$MultiPolygonToJson(MultiPolygon instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates
          ?.map((e) =>
              e?.map((e) => e?.map((e) => e?.toJson())?.toList())?.toList())
          ?.toList(),
      'bbox': instance.bbox?.toJson(),
    };

Map<String, dynamic> _$GeometryCollectionToJson(GeometryCollection instance) =>
    <String, dynamic>{
      'bbox': instance.bbox?.toJson(),
      'geometries': instance.geometries?.map((e) => e?.toJson())?.toList(),
    };

FeatureCollection _$FeatureCollectionFromJson(Map<String, dynamic> json) {
  return FeatureCollection(
    bbox: json['bbox'] == null
        ? null
        : BBox.fromJson((json['bbox'] as List)?.map((e) => e as num)?.toList()),
    features: (json['features'] as List)
        ?.map((e) =>
            e == null ? null : Feature.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$FeatureCollectionToJson(FeatureCollection instance) =>
    <String, dynamic>{
      'features': instance.features?.map((e) => e?.toJson())?.toList(),
      'bbox': instance.bbox?.toJson(),
    };
