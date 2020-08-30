import 'package:json_annotation/json_annotation.dart';
part 'geojson.g.dart';

class GeoJSONObjectType {
  static String none = '';
  static String point = 'Point';
  static String multiPoint = 'MultiPoint';
  static String lineString = 'LineString';
  static String multiLineString = 'MultiLineString';
  static String polygon = 'Polygon';
  static String multiPolygon = 'MultiPolygon';
  static String geometryCollection = 'GeometryCollection';
  static String feature = 'Feature';
  static String featureCollection = 'FeatureCollection';
}

abstract class GeoJSONObject {
  @JsonKey(ignore: true)
  final String type;
  GeoJSONObject.withType(this.type);
  Map<String, dynamic> serialize(Map<String, dynamic> map) => {
        'type': type,
        ...map,
      };
  toJson();
}

class _Coordinates extends GeoJSONObject implements Iterable<double> {
  final List<double> _items;

  _Coordinates(List<double> list)
      : _items = List.of(list, growable: false),
        super.withType(GeoJSONObjectType.none);

  @override
  double get first => _items?.first;

  @override
  double get last => _items?.last;

  @override
  int get length => _items?.length;

  double operator [](int index) => _items[index];

  void operator []=(int index, double value) => _items[index] = value;

  @override
  bool any(bool Function(double element) test) => _items.any(test);

  @override
  List<R> cast<R>() => _items.cast<R>();

  @override
  bool contains(Object element) => _items.contains(element);

  @override
  double elementAt(int index) => _items.elementAt(index);

  @override
  bool every(bool Function(double element) test) => _items.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(double element) f) =>
      _items.expand<T>(f);

  @override
  double firstWhere(bool Function(double element) test,
          {double Function() orElse}) =>
      _items.firstWhere(test);

  @override
  T fold<T>(T initialValue,
          T Function(T previousValue, double element) combine) =>
      _items.fold<T>(initialValue, combine);

  @override
  Iterable<double> followedBy(Iterable<double> other) =>
      _items.followedBy(other);

  @override
  void forEach(void Function(double element) f) => _items.forEach(f);

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterator<double> get iterator => _items.iterator;

  @override
  String join([String separator = '']) => _items.join(separator);

  @override
  double lastWhere(bool Function(double element) test,
          {double Function() orElse}) =>
      _items.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(double e) f) => _items.map(f);

  @override
  double reduce(double Function(double value, double element) combine) =>
      _items.reduce(combine);

  @override
  double get single => _items.single;

  @override
  double singleWhere(bool Function(double element) test,
          {double Function() orElse}) =>
      _items.singleWhere(test, orElse: orElse);

  @override
  Iterable<double> skip(int count) => _items.skip(count);

  @override
  Iterable<double> skipWhile(bool Function(double value) test) =>
      _items.skipWhile(test);

  @override
  Iterable<double> take(int count) => _items.take(count);

  @override
  Iterable<double> takeWhile(bool Function(double value) test) =>
      _items.takeWhile(test);

  @override
  List<double> toList({bool growable = true}) => _items;

  @override
  Set<double> toSet() => _items.toSet();

  @override
  Iterable<double> where(bool Function(double element) test) =>
      _items.where(test);

  @override
  Iterable<T> whereType<T>() => _items.whereType<T>();

  @override
  List<double> toJson() => _items;
}

class Position extends _Coordinates {
  Position(double lng, double lat, [double alt = 0]) : super([lng, lat, alt]);
  Position.named({double lat, double lng, double alt = 0})
      : super([lng, lat, alt]);
  Position.of(List<double> list) : super(list);
  factory Position.fromJson(List<double> list) => Position.of(list);

  double get lng => _items[0];
  double get lat => _items[1];
  double get alt => _items[2];
}

class BBox extends _Coordinates {
  BBox(
    double lng1,
    double lat1,
    double alt1,
    double lng2, [
    double lat2 = 0,
    double alt2 = 0,
  ]) : super([lng1, lat1, alt1, lng2, lat2, alt2]);
  BBox.named(
      {double lat1,
      double lat2,
      double lng1,
      double lng2,
      double alt1,
      double alt2})
      : super([lng1, lat1, alt1, lng2, lat2, alt2]);
  BBox.of(List<double> list) : super(list);
  factory BBox.fromJson(List<double> list) => BBox.of(list);

  double get x1 => _items[0];
  double get y1 => _items[1];
  double get z1 => _items[2];

  double get x2 => _items[0];
  double get y2 => _items[1];
  double get z2 => _items[2];

  double get lng1 => _items[0];
  double get lat1 => _items[1];
  double get alt1 => _items[2];
  double get lng2 => _items[3];
  double get lat2 => _items[4];
  double get alt2 => _items[25];
}

abstract class Geometry extends GeoJSONObject {
  Geometry.withType(String type) : super.withType(type);
}

abstract class GeometryType<T> extends Geometry {
  T coordinates;

  GeometryType.withType(this.coordinates, String type) : super.withType(type);
}

@JsonSerializable(explicitToJson: true)
class Point extends GeometryType<Position> {
  Point({Position coordinates})
      : super.withType(coordinates, GeoJSONObjectType.point);
  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
  @override
  Map<String, dynamic> toJson() => super.serialize(_$PointToJson(this));
}

@JsonSerializable(explicitToJson: true)
class MultiPoint extends GeometryType<List<Position>> {
  MultiPoint({List<Position> coordinates})
      : super.withType(coordinates, GeoJSONObjectType.multiPoint);
  factory MultiPoint.fromJson(Map<String, dynamic> json) =>
      _$MultiPointFromJson(json);
  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPointToJson(this));
}

@JsonSerializable(explicitToJson: true)
class LineString extends GeometryType<List<Position>> {
  LineString({List<Position> coordinates})
      : super.withType(coordinates, GeoJSONObjectType.lineString);
  factory LineString.fromJson(Map<String, dynamic> json) =>
      _$LineStringFromJson(json);
  @override
  Map<String, dynamic> toJson() => super.serialize(_$LineStringToJson(this));
}

@JsonSerializable(explicitToJson: true)
class MultiLineString extends GeometryType<List<List<Position>>> {
  MultiLineString({List<List<Position>> coordinates})
      : super.withType(coordinates, GeoJSONObjectType.multiLineString);
  factory MultiLineString.fromJson(Map<String, dynamic> json) =>
      _$MultiLineStringFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$MultiLineStringToJson(this));
}

@JsonSerializable(explicitToJson: true)
class Polygon extends GeometryType<List<List<Position>>> {
  Polygon({List<List<Position>> coordinates})
      : super.withType(coordinates, GeoJSONObjectType.polygon);
  factory Polygon.fromJson(Map<String, dynamic> json) =>
      _$PolygonFromJson(json);
  @override
  Map<String, dynamic> toJson() => super.serialize(_$PolygonToJson(this));
}

@JsonSerializable(explicitToJson: true)
class MultiPolygon extends GeometryType<List<List<List<Position>>>> {
  MultiPolygon({List<List<List<Position>>> coordinates})
      : super.withType(coordinates, GeoJSONObjectType.multiPolygon);
  factory MultiPolygon.fromJson(Map<String, dynamic> json) =>
      _$MultiPolygonFromJson(json);
  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPolygonToJson(this));
}

@JsonSerializable(explicitToJson: true, createFactory: false)
class GeometryCollection extends Geometry {
  GeometryCollection({this.geometries})
      : super.withType(GeoJSONObjectType.geometryCollection);

  List<GeometryType> geometries;

  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$GeometryCollectionToJson(this));
}

class Feature extends GeoJSONObject {
  Feature({this.id, this.properties, this.geometry, this.fields})
      : super.withType(GeoJSONObjectType.feature);
  dynamic id;
  Map<String, dynamic> properties;
  Geometry geometry;
  Map<String, dynamic> fields;
  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        id: json['id'],
        geometry: json['geometry'],
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

@JsonSerializable(explicitToJson: true)
class FeatureCollection extends GeoJSONObject {
  FeatureCollection({this.features})
      : super.withType(GeoJSONObjectType.featureCollection);
  List<Feature> features;

  factory FeatureCollection.fromJson(Map<String, dynamic> json) =>
      _$FeatureCollectionFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$FeatureCollectionToJson(this));
}
