import 'package:json_annotation/json_annotation.dart';
part 'geojson.g.dart';

//TODO assemble multipoint from points
//TODO assemble multilinestring from linestring
//TODO assemble polygon from 3 or more points

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
  GeoJSONObject clone();
}

/// Coordinate types, following https://tools.ietf.org/html/rfc7946#section-4
abstract class CoordinateType implements Iterable<num> {
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

  CoordinateType clone();

  CoordinateType toSigned();

  bool get isSigned;
  _untilSigned(val, limit) {
    if (val > limit) {
      return _untilSigned(val - 360, limit);
    } else {
      return val;
    }
  }
}

// Position, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.1
/// Please make sure, you arrange your parameters like this:
/// 1. Longitude, 2. Latitude, 3. Altitude (optional)
class Position extends CoordinateType {
  Position(num lng, num lat, [num alt = 0]) : super([lng, lat, alt]);
  Position.named({num lat, num lng, num alt = 0}) : super([lng, lat, alt]);

  /// Position.of([<Lng>, <Lat>, <Alt (optional)>])
  Position.of(List<num> list)
      : super(list.length < 3
            ? [
                ...list,
                ...List.generate(3 - list.length, (val) => 0).toList(),
              ]
            : list);
  factory Position.fromJson(List<num> list) => Position.of(list);

  // TODO implement override operators +, -, * with vector operations

  @override
  bool operator ==(dynamic other) => other is Position
      ? lat == other.lat && lng == other.lng && alt == other.alt
      : false;

  num get lng => _items[0];
  num get lat => _items[1];
  num get alt => _items[2];

  @override
  bool get isSigned => lng <= 180 && lat <= 90;

  @override
  Position toSigned() => Position.named(
        lng: _untilSigned(lng, 180),
        lat: _untilSigned(lat, 90),
        alt: alt,
      );

  @override
  Position clone() => Position.of(_items);
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
  BBox.named(
      {num lat1, num lat2, num lng1, num lng2, num alt1 = 0, num alt2 = 0})
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

  @override
  BBox clone() => BBox.of(_items);

  @override
  bool get isSigned => lng1 <= 180 && lng2 <= 180 && lat1 <= 90 && lat2 <= 90;

  @override
  BBox toSigned() => BBox.named(
        alt1: alt1 ?? 0,
        alt2: alt2 ?? 0,
        lat1: _untilSigned(lat1, 90),
        lat2: _untilSigned(lat2, 90),
        lng1: _untilSigned(lng1, 180),
        lng2: _untilSigned(lng2, 180),
      );
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
  bool operator ==(dynamic other) =>
      other is Point ? coordinates == other.coordinates : false;

  @override
  Map<String, dynamic> toJson() => super.serialize(_$PointToJson(this));

  @override
  Point clone() =>
      Point(coordinates: coordinates?.clone(), bbox: bbox?.clone());
}

/// MultiPoint, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.3
@JsonSerializable(explicitToJson: true)
class MultiPoint extends GeometryType<List<Position>> {
  MultiPoint({this.bbox, List<Position> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectTypes.multiPoint);
  factory MultiPoint.fromJson(Map<String, dynamic> json) =>
      _$MultiPointFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPointToJson(this));

  @override
  MultiPoint clone() => MultiPoint(
        coordinates: coordinates?.map((e) => e?.clone())?.toList(),
        bbox: bbox?.clone(),
      );
}

/// LineString, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.4
@JsonSerializable(explicitToJson: true)
class LineString extends GeometryType<List<Position>> {
  LineString({this.bbox, List<Position> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectTypes.lineString);
  factory LineString.fromJson(Map<String, dynamic> json) =>
      _$LineStringFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$LineStringToJson(this));

  @override
  LineString clone() => LineString(
      coordinates: coordinates?.map((e) => e?.clone())?.toList(),
      bbox: bbox?.clone());
}

/// MultiLineString, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.5
@JsonSerializable(explicitToJson: true)
class MultiLineString extends GeometryType<List<List<Position>>> {
  MultiLineString({this.bbox, List<List<Position>> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectTypes.multiLineString);
  factory MultiLineString.fromJson(Map<String, dynamic> json) =>
      _$MultiLineStringFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$MultiLineStringToJson(this));

  @override
  MultiLineString clone() => MultiLineString(
        coordinates: coordinates
            ?.map((e) => e?.map((e) => e?.clone())?.toList())
            ?.toList(),
        bbox: bbox?.clone(),
      );
}

/// Polygon, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.6
@JsonSerializable(explicitToJson: true)
class Polygon extends GeometryType<List<List<Position>>> {
  Polygon({this.bbox, List<List<Position>> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectTypes.polygon);
  factory Polygon.fromJson(Map<String, dynamic> json) =>
      _$PolygonFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$PolygonToJson(this));

  @override
  Polygon clone() => Polygon(
        coordinates: coordinates
            ?.map((e) => e?.map((e) => e?.clone())?.toList())
            ?.toList(),
        bbox: bbox?.clone(),
      );
}

/// MultiPolygon, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.7
@JsonSerializable(explicitToJson: true)
class MultiPolygon extends GeometryType<List<List<List<Position>>>> {
  MultiPolygon({this.bbox, List<List<List<Position>>> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectTypes.multiPolygon);
  factory MultiPolygon.fromJson(Map<String, dynamic> json) =>
      _$MultiPolygonFromJson(json);
  @override
  BBox bbox;
  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPolygonToJson(this));

  @override
  GeoJSONObject clone() => MultiPolygon(
        coordinates: coordinates
            ?.map((e) =>
                e?.map((e) => e?.map((e) => e?.clone())?.toList())?.toList())
            ?.toList(),
        bbox: bbox?.clone(),
      );
}

/// GeometryCollection, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.8
@JsonSerializable(explicitToJson: true, createFactory: false)
class GeometryCollection extends Geometry {
  GeometryCollection({this.bbox, this.geometries = const []})
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

  @override
  GeoJSONObject clone() => GeometryCollection(
        geometries: geometries?.map((e) => e?.clone())?.toList(),
        bbox: bbox?.clone(),
      );
}

/// Feature, as specified here https://tools.ietf.org/html/rfc7946#section-3.2
class Feature<T extends Geometry> extends GeoJSONObject {
  Feature({
    this.bbox,
    this.id,
    this.properties = const {},
    this.geometry,
    this.fields = const {},
  }) : super.withType(GeoJSONObjectTypes.feature);
  dynamic id;
  Map<String, dynamic> properties;
  T geometry;
  Map<String, dynamic> fields;

  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'properties':
        return properties;
      case 'geometry':
        return geometry;
      case 'type':
        return type;
      case 'bbox':
        return bbox;
      default:
        return fields != null ? fields[key] : null;
    }
  }

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
        if (fields != null) ...fields,
        'id': id,
        'geometry': geometry.toJson(),
        'properties': properties,
      });

  @override
  Feature<T> clone() => Feature<T>(
        geometry: geometry?.clone(),
        bbox: bbox?.clone(),
        fields: Map.of(fields),
        properties: Map.of(properties),
        id: id,
      );
}

/// FeatureCollection, as specified here https://tools.ietf.org/html/rfc7946#section-3.3
@JsonSerializable(explicitToJson: true)
class FeatureCollection<T extends Geometry> extends GeoJSONObject {
  FeatureCollection({this.bbox, this.features = const []})
      : super.withType(GeoJSONObjectTypes.featureCollection);
  List<Feature<T>> features;
  @override
  BBox bbox;
  factory FeatureCollection.fromJson(Map<String, dynamic> json) =>
      _$FeatureCollectionFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$FeatureCollectionToJson(this));

  @override
  FeatureCollection<T> clone() => FeatureCollection(
        features: features?.map((e) => e?.clone())?.toList(),
        bbox: bbox?.clone(),
      );
}
