import 'package:json_annotation/json_annotation.dart';
part 'geojson.g.dart';

class GeoJSONObjectTypes {
  static const String point = 'Point';
  static const String multiPoint = 'MultiPoint';
  static const String lineString = 'LineString';
  static const String multiLineString = 'MultiLineString';
  static const String polygon = 'Polygon';
  static const String multiPolygon = 'MultiPolygon';
  static const String geometryCollection = 'GeometryCollection';
  static const String feature = 'Feature';
  static const String featureCollection = 'FeatureCollection';
}

abstract class GeoJSONObject {
  @JsonKey(ignore: true)
  final String type;
  BBox bbox;
  GeoJSONObject.withType(this.type);
  Map<String, dynamic> serialize(Map<String, dynamic> map) => {
        'type': type,
        ...map,
      };
  toJson();
}

/// Coordinate types, following https://tools.ietf.org/html/rfc7946#section-4
class CoordinateType implements Iterable<num> {
  final List<num> _items;

  CoordinateType(List<num> list) : _items = List.of(list, growable: false);

  @override
  num get first => _items?.first;

  @override
  num get last => _items?.last;

  @override
  int get length => _items?.length;

  num operator [](int index) => _items[index];

  void operator []=(int index, num value) => _items[index] = value;

  @override
  bool any(bool Function(num element) test) => _items.any(test);

  @override
  List<R> cast<R>() => _items.cast<R>();

  @override
  bool contains(Object element) => _items.contains(element);

  @override
  num elementAt(int index) => _items.elementAt(index);

  @override
  bool every(bool Function(num element) test) => _items.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(num element) f) =>
      _items.expand<T>(f);

  @override
  num firstWhere(bool Function(num element) test, {num Function() orElse}) =>
      _items.firstWhere(test);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, num element) combine) =>
      _items.fold<T>(initialValue, combine);

  @override
  Iterable<num> followedBy(Iterable<num> other) => _items.followedBy(other);

  @override
  void forEach(void Function(num element) f) => _items.forEach(f);

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterator<num> get iterator => _items.iterator;

  @override
  String join([String separator = '']) => _items.join(separator);

  @override
  num lastWhere(bool Function(num element) test, {num Function() orElse}) =>
      _items.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(num e) f) => _items.map(f);

  @override
  num reduce(num Function(num value, num element) combine) =>
      _items.reduce(combine);

  @override
  num get single => _items.single;

  @override
  num singleWhere(bool Function(num element) test, {num Function() orElse}) =>
      _items.singleWhere(test, orElse: orElse);

  @override
  Iterable<num> skip(int count) => _items.skip(count);

  @override
  Iterable<num> skipWhile(bool Function(num value) test) =>
      _items.skipWhile(test);

  @override
  Iterable<num> take(int count) => _items.take(count);

  @override
  Iterable<num> takeWhile(bool Function(num value) test) =>
      _items.takeWhile(test);

  @override
  List<num> toList({bool growable = true}) => _items;

  @override
  Set<num> toSet() => _items.toSet();

  @override
  Iterable<num> where(bool Function(num element) test) => _items.where(test);

  @override
  Iterable<T> whereType<T>() => _items.whereType<T>();

  List<num> toJson() => _items;
}

/// Position, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.1
/// Please make sure, you arrange your parameters like this:
/// 1. Longitude, 2. Latitude, 3. Altitude (optional)
class Position extends CoordinateType {
  Position(num lng, num lat, [num alt = 0]) : super([lng, lat, alt]);
  Position.named({num lat, num lng, num alt = 0}) : super([lng, lat, alt]);

  /// Position.of([<Lng>, <Lat>, <Alt (optional)>])
  Position.of(List<num> list) : super(list);
  factory Position.fromJson(List<num> list) => Position.of(list);

  num get lng => _items[0];
  num get lat => _items[1];
  num get alt => _items[2];
}

// Bounding box, as specified here https://tools.ietf.org/html/rfc7946#section-5
/// Please make sure, you arrange your parameters like this:
/// Longitude 1, Latitude 1, Altitude 1 (optional), Longitude 2, Latitude 2, Altitude 2 (optional)
/// You can either specify 4 or 6 parameters
class BBox extends CoordinateType {
  BBox(
    num lng1,
    num lat1,
    num alt1,
    num lng2, [
    num lat2 = 0,
    num alt2 = 0,
  ]) : super([lng1, lat1, alt1, lng2, lat2, alt2]);
  BBox.named({num lat1, num lat2, num lng1, num lng2, num alt1, num alt2})
      : super([lng1, lat1, alt1, lng2, lat2, alt2]);

  /// Position.of([<Lng>, <Lat>, <Alt (optional)>])
  BBox.of(List<num> list) : super(list);
  factory BBox.fromJson(List<num> list) => BBox.of(list);

  num get lng1 => _items[0];
  num get lat1 => _items[1];
  num get alt1 => _items[2];
  num get lng2 => _items[3];
  num get lat2 => _items[4];
  num get alt2 => _items[5];
}

abstract class Geometry extends GeoJSONObject {
  Geometry.withType(String type) : super.withType(type);
  static Geometry deserialize(Map<String, dynamic> json) {
    return json['type'] == GeoJSONObjectTypes.geometryCollection
        ? GeometryCollection.fromJson(json)
        : GeometryType.deserialize(json);
  }
}

abstract class GeometryType<T> extends Geometry {
  T coordinates;
  GeometryType.withType(this.coordinates, String type) : super.withType(type);

  static GeometryType deserialize(Map<String, dynamic> json) {
    switch (json['type']) {
      case GeoJSONObjectTypes.point:
        return Point.fromJson(json);
      case GeoJSONObjectTypes.multiPoint:
        return MultiPoint.fromJson(json);
      case GeoJSONObjectTypes.lineString:
        return LineString.fromJson(json);
      case GeoJSONObjectTypes.multiLineString:
        return MultiLineString.fromJson(json);
      case GeoJSONObjectTypes.polygon:
        return Polygon.fromJson(json);
      case GeoJSONObjectTypes.multiPolygon:
        return MultiPolygon.fromJson(json);
      default:
        throw Exception('${json['type']} is not a valid GeoJSON type');
    }
  }
}

/// Point, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.2
@JsonSerializable(explicitToJson: true)
class Point extends GeometryType<Position> {
  Point({this.bbox, Position coordinates})
      : super.withType(coordinates, GeoJSONObjectTypes.point);
  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$PointToJson(this));
}

/// MultiPoint, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.3
@JsonSerializable(explicitToJson: true)
class MultiPoint extends GeometryType<List<Position>> {
  MultiPoint({this.bbox, List<Position> coordinates})
      : super.withType(coordinates, GeoJSONObjectTypes.multiPoint);
  factory MultiPoint.fromJson(Map<String, dynamic> json) =>
      _$MultiPointFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPointToJson(this));
}

/// LineString, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.4
@JsonSerializable(explicitToJson: true)
class LineString extends GeometryType<List<Position>> {
  LineString({this.bbox, List<Position> coordinates})
      : super.withType(coordinates, GeoJSONObjectTypes.lineString);
  factory LineString.fromJson(Map<String, dynamic> json) =>
      _$LineStringFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$LineStringToJson(this));
}

/// MultiLineString, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.5
@JsonSerializable(explicitToJson: true)
class MultiLineString extends GeometryType<List<List<Position>>> {
  MultiLineString({this.bbox, List<List<Position>> coordinates})
      : super.withType(coordinates, GeoJSONObjectTypes.multiLineString);
  factory MultiLineString.fromJson(Map<String, dynamic> json) =>
      _$MultiLineStringFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$MultiLineStringToJson(this));
}

/// Polygon, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.6
@JsonSerializable(explicitToJson: true)
class Polygon extends GeometryType<List<List<Position>>> {
  Polygon({this.bbox, List<List<Position>> coordinates})
      : super.withType(coordinates, GeoJSONObjectTypes.polygon);
  factory Polygon.fromJson(Map<String, dynamic> json) =>
      _$PolygonFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$PolygonToJson(this));
}

/// MultiPolygon, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.7
@JsonSerializable(explicitToJson: true)
class MultiPolygon extends GeometryType<List<List<List<Position>>>> {
  MultiPolygon({this.bbox, List<List<List<Position>>> coordinates})
      : super.withType(coordinates, GeoJSONObjectTypes.multiPolygon);
  factory MultiPolygon.fromJson(Map<String, dynamic> json) =>
      _$MultiPolygonFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPolygonToJson(this));
}

/// GeometryCollection, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.8
@JsonSerializable(explicitToJson: true, createFactory: false)
class GeometryCollection extends Geometry {
  GeometryCollection({this.bbox, this.geometries})
      : super.withType(GeoJSONObjectTypes.geometryCollection);
  @override
  BBox bbox;
  List<GeometryType> geometries;
  factory GeometryCollection.fromJson(Map<String, dynamic> json) =>
      GeometryCollection(
        geometries: json['geometries'] == null
            ? null
            : (json['geometries'] as List)
                .map((e) => GeometryType.deserialize(e))
                .toList(),
      );
  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$GeometryCollectionToJson(this));
}

/// Feature, as specified here https://tools.ietf.org/html/rfc7946#section-3.2
class Feature<T extends Geometry> extends GeoJSONObject {
  Feature({this.bbox, this.id, this.properties, this.geometry, this.fields})
      : super.withType(GeoJSONObjectTypes.feature);
  dynamic id;
  Map<String, dynamic> properties;
  T geometry;
  Map<String, dynamic> fields;
  @override
  BBox bbox;
  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        id: json['id'],
        geometry: Geometry.deserialize(json['geometry']),
        properties: json['properties'],
        fields: Map.fromEntries(
          json.entries.where(
            (el) =>
                el.key != 'geometry' &&
                el.key != 'properties' &&
                el.key != 'id',
          ),
        ),
      );
  @override
  Map<String, dynamic> toJson() => super.serialize({
        ...fields,
        'id': id,
        'geometry': geometry.toJson(),
        'properties': properties,
      });
}

/// FeatureCollection, as specified here https://tools.ietf.org/html/rfc7946#section-3.3
@JsonSerializable(explicitToJson: true)
class FeatureCollection<T extends Geometry> extends GeoJSONObject {
  FeatureCollection({this.bbox, this.features})
      : super.withType(GeoJSONObjectTypes.featureCollection);
  List<Feature<T>> features;
  @override
  BBox bbox;
  factory FeatureCollection.fromJson(Map<String, dynamic> json) =>
      _$FeatureCollectionFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$FeatureCollectionToJson(this));
}
