import 'package:json_annotation/json_annotation.dart';
part 'geojson.g.dart';

enum GeoJSONObjectType {
  point,
  multiPoint,
  lineString,
  multiLineString,
  polygon,
  multiPolygon,
  geometryCollection,
  feature,
  featureCollection,
}

abstract class GeoJSONObject {
  // TODO implement type
}

class _Coordinates extends GeoJSONObject implements Iterable<double> {
  final List<double> _items;

  _Coordinates(List<double> list) : _items = List.of(list, growable: false);

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

  List<double> toJson() => _items;
}

class Position extends _Coordinates {
  Position(double x, double y, [double z = 0]) : super([x, y, z]);
  Position.named({double lat, double lng, double alt = 0})
      : super([lng, lat, alt]);
  Position.of(List<double> list) : super(list);
  factory Position.fromJson(List<double> list) => Position.of(list);

  double get lng => _items[0];
  double get x => _items[0];
  double get lat => _items[1];
  double get y => _items[1];
  double get alt => _items[2];
  double get z => _items[2];
}

class BBox extends _Coordinates {
  BBox(
    double x1,
    double x2,
    double y1,
    double y2, [
    double z1 = 0,
    double z2 = 0,
  ]) : super([x1, y1, z1, x2, y2, z2]);
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

/* TODO implement
  double get x1 => _items[0];
  double get lat1 => _items[0];
  double get lng1 => _items[1];
  double get y1 => _items[1];
  double get alt1 => _items[2];
  double get z1 => _items[2];
  double get lat2 => _items[0];
  double get x2 => _items[0];
  double get lng2 => _items[1];
  double get y2 => _items[1];
  double get alt2 => _items[2];
  double get z2 => _items[2];*/
}

abstract class Geometry extends GeoJSONObject {}

abstract class GeometryType<T> extends Geometry {
  T coordinates;

  GeometryType(this.coordinates);
}

@JsonSerializable()
class Point extends GeometryType<Position> {
  Point({coordinates}) : super(coordinates);
  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
  Map<String, dynamic> toJson() => _$PointToJson(this);
}

class MultiPoint extends GeometryType<List<Position>> {
  MultiPoint({coordinates}) : super(coordinates);
}

class LineString extends GeometryType<List<Position>> {
  LineString({coordinates}) : super(coordinates);
}

class MultiLineString extends GeometryType<List<List<Position>>> {
  MultiLineString({coordinates}) : super(coordinates);
}

class Polygon extends GeometryType<List<List<Position>>> {
  Polygon({coordinates}) : super(coordinates);
}

class MultiPolygon extends GeometryType<List<List<List<Position>>>> {
  MultiPolygon({coordinates}) : super(coordinates);
}

class GeometryCollection extends Geometry {
  GeometryCollection({this.geometries});

  List<GeometryType> geometries;
}

class Feature extends GeoJSONObject {
  Feature({this.id, this.properties, this.geometry});
  dynamic id;
  Map<String, dynamic> properties;
  Geometry geometry;
}

class FeatureCollection extends GeoJSONObject {
  FeatureCollection({this.features});
  List<Feature> features;
}
