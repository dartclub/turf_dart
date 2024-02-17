// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geojson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Point _$PointFromJson(Map<String, dynamic> json) => Point(
      bbox: json['bbox'] == null
          ? null
          : BBox.fromJson(
              (json['bbox'] as List<dynamic>).map((e) => e as num).toList()),
      coordinates: Position.fromJson(
          (json['coordinates'] as List<dynamic>).map((e) => e as num).toList()),
    );

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
      'bbox': instance.bbox?.toJson(),
      'coordinates': instance.coordinates.toJson(),
    };

MultiPoint _$MultiPointFromJson(Map<String, dynamic> json) => MultiPoint(
      bbox: json['bbox'] == null
          ? null
          : BBox.fromJson(
              (json['bbox'] as List<dynamic>).map((e) => e as num).toList()),
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => Position.fromJson(
                  (e as List<dynamic>).map((e) => e as num).toList()))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MultiPointToJson(MultiPoint instance) =>
    <String, dynamic>{
      'bbox': instance.bbox?.toJson(),
      'coordinates': instance.coordinates.map((e) => e.toJson()).toList(),
    };

LineString _$LineStringFromJson(Map<String, dynamic> json) => LineString(
      bbox: json['bbox'] == null
          ? null
          : BBox.fromJson(
              (json['bbox'] as List<dynamic>).map((e) => e as num).toList()),
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => Position.fromJson(
                  (e as List<dynamic>).map((e) => e as num).toList()))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LineStringToJson(LineString instance) =>
    <String, dynamic>{
      'bbox': instance.bbox?.toJson(),
      'coordinates': instance.coordinates.map((e) => e.toJson()).toList(),
    };

MultiLineString _$MultiLineStringFromJson(Map<String, dynamic> json) =>
    MultiLineString(
      bbox: json['bbox'] == null
          ? null
          : BBox.fromJson(
              (json['bbox'] as List<dynamic>).map((e) => e as num).toList()),
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) => Position.fromJson(
                      (e as List<dynamic>).map((e) => e as num).toList()))
                  .toList())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MultiLineStringToJson(MultiLineString instance) =>
    <String, dynamic>{
      'bbox': instance.bbox?.toJson(),
      'coordinates': instance.coordinates
          .map((e) => e.map((e) => e.toJson()).toList())
          .toList(),
    };

Polygon _$PolygonFromJson(Map<String, dynamic> json) => Polygon(
      bbox: json['bbox'] == null
          ? null
          : BBox.fromJson(
              (json['bbox'] as List<dynamic>).map((e) => e as num).toList()),
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) => Position.fromJson(
                      (e as List<dynamic>).map((e) => e as num).toList()))
                  .toList())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PolygonToJson(Polygon instance) => <String, dynamic>{
      'bbox': instance.bbox?.toJson(),
      'coordinates': instance.coordinates
          .map((e) => e.map((e) => e.toJson()).toList())
          .toList(),
    };

MultiPolygon _$MultiPolygonFromJson(Map<String, dynamic> json) => MultiPolygon(
      bbox: json['bbox'] == null
          ? null
          : BBox.fromJson(
              (json['bbox'] as List<dynamic>).map((e) => e as num).toList()),
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) => (e as List<dynamic>)
                      .map((e) => Position.fromJson(
                          (e as List<dynamic>).map((e) => e as num).toList()))
                      .toList())
                  .toList())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MultiPolygonToJson(MultiPolygon instance) =>
    <String, dynamic>{
      'bbox': instance.bbox?.toJson(),
      'coordinates': instance.coordinates
          .map((e) => e.map((e) => e.map((e) => e.toJson()).toList()).toList())
          .toList(),
    };

Map<String, dynamic> _$GeometryCollectionToJson(GeometryCollection instance) =>
    <String, dynamic>{
      'type': _$GeoJSONObjectTypeEnumMap[instance.type]!,
      'bbox': instance.bbox?.toJson(),
      'geometries': instance.geometries.map((e) => e.toJson()).toList(),
    };

const _$GeoJSONObjectTypeEnumMap = {
  GeoJSONObjectType.point: 'Point',
  GeoJSONObjectType.multiPoint: 'MultiPoint',
  GeoJSONObjectType.lineString: 'LineString',
  GeoJSONObjectType.multiLineString: 'MultiLineString',
  GeoJSONObjectType.polygon: 'Polygon',
  GeoJSONObjectType.multiPolygon: 'MultiPolygon',
  GeoJSONObjectType.geometryCollection: 'GeometryCollection',
  GeoJSONObjectType.feature: 'Feature',
  GeoJSONObjectType.featureCollection: 'FeatureCollection',
};
