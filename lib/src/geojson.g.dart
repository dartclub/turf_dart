// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geojson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Point _$PointFromJson(Map<String, dynamic> json) {
  return Point(
    coordinates: json['coordinates'] == null
        ? null
        : Position.fromJson((json['coordinates'] as List)
            ?.map((e) => (e as num)?.toDouble())
            ?.toList()),
  );
}

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
      'coordinates': instance.coordinates?.toJson(),
    };

MultiPoint _$MultiPointFromJson(Map<String, dynamic> json) {
  return MultiPoint(
    coordinates: (json['coordinates'] as List)
        ?.map((e) => e == null
            ? null
            : Position.fromJson(
                (e as List)?.map((e) => (e as num)?.toDouble())?.toList()))
        ?.toList(),
  );
}

Map<String, dynamic> _$MultiPointToJson(MultiPoint instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates?.map((e) => e?.toJson())?.toList(),
    };

LineString _$LineStringFromJson(Map<String, dynamic> json) {
  return LineString(
    coordinates: (json['coordinates'] as List)
        ?.map((e) => e == null
            ? null
            : Position.fromJson(
                (e as List)?.map((e) => (e as num)?.toDouble())?.toList()))
        ?.toList(),
  );
}

Map<String, dynamic> _$LineStringToJson(LineString instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates?.map((e) => e?.toJson())?.toList(),
    };

MultiLineString _$MultiLineStringFromJson(Map<String, dynamic> json) {
  return MultiLineString(
    coordinates: (json['coordinates'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : Position.fromJson(
                    (e as List)?.map((e) => (e as num)?.toDouble())?.toList()))
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$MultiLineStringToJson(MultiLineString instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates
          ?.map((e) => e?.map((e) => e?.toJson())?.toList())
          ?.toList(),
    };

Polygon _$PolygonFromJson(Map<String, dynamic> json) {
  return Polygon(
    coordinates: (json['coordinates'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : Position.fromJson(
                    (e as List)?.map((e) => (e as num)?.toDouble())?.toList()))
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$PolygonToJson(Polygon instance) => <String, dynamic>{
      'coordinates': instance.coordinates
          ?.map((e) => e?.map((e) => e?.toJson())?.toList())
          ?.toList(),
    };

MultiPolygon _$MultiPolygonFromJson(Map<String, dynamic> json) {
  return MultiPolygon(
    coordinates: (json['coordinates'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => (e as List)
                ?.map((e) => e == null
                    ? null
                    : Position.fromJson((e as List)
                        ?.map((e) => (e as num)?.toDouble())
                        ?.toList()))
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
    };

Map<String, dynamic> _$GeometryCollectionToJson(GeometryCollection instance) =>
    <String, dynamic>{
      'geometries': instance.geometries?.map((e) => e?.toJson())?.toList(),
    };

FeatureCollection _$FeatureCollectionFromJson(Map<String, dynamic> json) {
  return FeatureCollection(
    features: (json['features'] as List)
        ?.map((e) =>
            e == null ? null : Feature.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$FeatureCollectionToJson(FeatureCollection instance) =>
    <String, dynamic>{
      'features': instance.features?.map((e) => e?.toJson())?.toList(),
    };
