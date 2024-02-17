import 'package:json_annotation/json_annotation.dart';

part 'geojson.g.dart';

@JsonEnum(alwaysCreate: true)
enum GeoJSONObjectType {
  @JsonValue('Point')
  point,
  @JsonValue('MultiPoint')
  multiPoint,
  @JsonValue('LineString')
  lineString,
  @JsonValue('MultiLineString')
  multiLineString,
  @JsonValue('Polygon')
  polygon,
  @JsonValue('MultiPolygon')
  multiPolygon,
  @JsonValue('GeometryCollection')
  geometryCollection,
  @JsonValue('Feature')
  feature,
  @JsonValue('FeatureCollection')
  featureCollection,
}

abstract class GeoJSONObject {
  final GeoJSONObjectType type;
  BBox? bbox;

  GeoJSONObject.withType(this.type, {this.bbox});

  Map<String, dynamic> serialize(Map<String, dynamic> map) => {
        'type': _$GeoJSONObjectTypeEnumMap[type],
        ...map,
      };

  static GeoJSONObject fromJson(Map<String, dynamic> json) {
    GeoJSONObjectType decoded = json['type'] is GeoJSONObjectType
        ? json['type']
        : $enumDecode(_$GeoJSONObjectTypeEnumMap, json['type']);
    switch (decoded) {
      case GeoJSONObjectType.point:
        return Point.fromJson(json);
      case GeoJSONObjectType.multiPoint:
        return MultiPoint.fromJson(json);
      case GeoJSONObjectType.lineString:
        return LineString.fromJson(json);
      case GeoJSONObjectType.multiLineString:
        return MultiLineString.fromJson(json);
      case GeoJSONObjectType.polygon:
        return Polygon.fromJson(json);
      case GeoJSONObjectType.multiPolygon:
        return MultiPolygon.fromJson(json);
      case GeoJSONObjectType.geometryCollection:
        return GeometryCollection.fromJson(json);
      case GeoJSONObjectType.feature:
        return Feature.fromJson(json);
      case GeoJSONObjectType.featureCollection:
        return FeatureCollection.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

  GeoJSONObject clone();
}

/// Coordinate types, following https://tools.ietf.org/html/rfc7946#section-4
abstract class CoordinateType implements Iterable<num> {
  final List<num> _items;

  CoordinateType(List<num> list) : _items = List.of(list, growable: false);

  @override
  num get first => _items.first;

  @override
  num get last => _items.last;

  @override
  int get length => _items.length;

  num? operator [](int index) => _items[index];

  void operator []=(int index, num value) => _items[index] = value;

  @override
  bool any(bool Function(num element) test) => _items.any(test);

  @override
  List<R> cast<R>() => _items.cast<R>();

  @override
  bool contains(Object? element) => _items.contains(element);

  @override
  num elementAt(int index) => _items.elementAt(index);

  @override
  bool every(bool Function(num element) test) => _items.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(num element) f) =>
      _items.expand<T>(f);

  @override
  num firstWhere(bool Function(num element) test, {num Function()? orElse}) =>
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
  num lastWhere(bool Function(num element) test, {num Function()? orElse}) =>
      _items.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(num e) f) => _items.map(f);

  @override
  num reduce(num Function(num value, num element) combine) =>
      _items.reduce(combine);

  @override
  num get single => _items.single;

  @override
  num singleWhere(bool Function(num element) test, {num Function()? orElse}) =>
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

  num _untilSigned(num val, limit) {
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
  Position(num lng, num lat, [num? alt])
      : super([
          lng,
          lat,
          if (alt != null) alt,
        ]);

  Position.named({required num lat, required num lng, num? alt})
      : super([
          lng,
          lat,
          if (alt != null) alt,
        ]);

  /// Position.of([<Lng>, <Lat>, <Alt (optional)>])
  Position.of(super.list) : assert(list.length >= 2 && list.length <= 3);

  factory Position.fromJson(List<num> list) => Position.of(list);

  Position operator +(Position p) => Position.of([
        lng + p.lng,
        lat + p.lat,
        if (alt != null && p.alt != null) alt! + p.alt!
      ]);

  Position operator -(Position p) => Position.of([
        lng - p.lng,
        lat - p.lat,
        if (alt != null && p.alt != null) alt! - p.alt!,
      ]);

  num dotProduct(Position p) =>
      (lng * p.lng) +
      (lat * p.lat) +
      (alt != null && p.alt != null ? (alt! * p.alt!) : 0);

  Position crossProduct(Position p) {
    if (alt != null && p.alt != null) {
      return Position(
        lat * p.alt! - alt! * p.lat,
        alt! * p.lng - lng * p.alt!,
        lng * p.lat - lat * p.lng,
      );
    }
    throw Exception('Cross product only implemented for 3 dimensions');
  }

  Position operator *(Position p) => crossProduct(p);

  num get lng => _items[0];

  num get lat => _items[1];

  num? get alt => length == 3 ? _items[2] : null;

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

  @override
  int get hashCode => Object.hashAll(_items);

  @override
  bool operator ==(Object other) => other is Position
      ? lng == other.lng && lat == other.lat && alt == other.alt
      : false;
}

// Bounding box, as specified here https://tools.ietf.org/html/rfc7946#section-5
/// Please make sure, you arrange your parameters like this:
/// Longitude 1, Latitude 1, Altitude 1 (optional), Longitude 2, Latitude 2, Altitude 2 (optional)
/// You can either specify 4 or 6 parameters
/// If you are using the default constructor with two dimensional positions (lng + lat only), please use the constructor like this:
/// `BBox(lng1, lat1, lng2, lat2);`
class BBox extends CoordinateType {
  BBox(
    /// longitude 1
    num lng1,

    /// latitude 1
    num lat1,

    /// longitude 2 for 2 dim. positions; altitude 1 for 3 dim. positions
    num alt1,

    /// latitude 2 for 2 dim. positions; longitude 2 for 3 dim. positions
    num lng2, [
    /// latitude 2 for 3 dim. positions
    num? lat2,

    /// altitude 2 for 3 dim. positions
    num? alt2,
  ]) : super([
          lng1,
          lat1,
          alt1,
          lng2,
          if (lat2 != null) lat2,
          if (alt2 != null) alt2,
        ]);

  BBox.named({
    required num lng1,
    required num lat1,
    num? alt1,
    required num lng2,
    required num lat2,
    num? alt2,
  }) : super([
          lng1,
          lat1,
          if (alt1 != null) alt1,
          lng2,
          lat2,
          if (alt2 != null) alt2,
        ]);

  /// Position.of([<Lng>, <Lat>, <Alt (optional)>])
  BBox.of(super.list) : assert(list.length == 4 || list.length == 6);

  factory BBox.fromJson(List<num> list) => BBox.of(list);

  bool get _is3D => length == 6;

  num get lng1 => _items[0];

  num get lat1 => _items[1];

  num? get alt1 => _is3D ? _items[2] : null;

  num get lng2 => _items[_is3D ? 3 : 2];

  num get lat2 => _items[_is3D ? 4 : 3];

  num? get alt2 => _is3D ? _items[5] : null;

  BBox copyWith({
    num? lng1,
    num? lat1,
    num? alt1,
    num? lat2,
    num? lng2,
    num? alt2,
  }) =>
      BBox.named(
        lng1: lng1 ?? this.lng1,
        lat1: lat1 ?? this.lat1,
        alt1: alt1 ?? this.alt1,
        lng2: lng2 ?? this.lng2,
        lat2: lat2 ?? this.lat2,
        alt2: alt2 ?? this.alt2,
      );

  @override
  BBox clone() => BBox.of(_items);

  @override
  bool get isSigned => lng1 <= 180 && lng2 <= 180 && lat1 <= 90 && lat2 <= 90;

  @override
  BBox toSigned() => BBox.named(
        alt1: alt1,
        alt2: alt2,
        lat1: _untilSigned(lat1, 90),
        lat2: _untilSigned(lat2, 90),
        lng1: _untilSigned(lng1, 180),
        lng2: _untilSigned(lng2, 180),
      );

  @override
  int get hashCode => Object.hashAll(_items);

  @override
  bool operator ==(Object other) => other is BBox
      ? lng1 == other.lng1 &&
          lat1 == other.lat1 &&
          alt1 == other.alt1 &&
          lng2 == other.lng2 &&
          lat2 == other.lat2 &&
          alt2 == other.alt2
      : false;
}

abstract class GeometryObject extends GeoJSONObject {
  GeometryObject.withType(super.type, {super.bbox}) : super.withType();

  static GeometryObject deserialize(Map<String, dynamic> json) {
    return json['type'] == 'GeometryCollection' ||
            json['type'] == GeoJSONObjectType.geometryCollection
        ? GeometryCollection.fromJson(json)
        : GeometryType.deserialize(json);
  }
}

abstract class GeometryType<T> extends GeometryObject {
  T coordinates;

  GeometryType.withType(this.coordinates, GeoJSONObjectType type, {BBox? bbox})
      : super.withType(type, bbox: bbox);

  static GeometryType deserialize(Map<String, dynamic> json) {
    GeoJSONObjectType decoded = json['type'] is GeoJSONObjectType
        ? json['type']
        : $enumDecode(_$GeoJSONObjectTypeEnumMap, json['type']);
    switch (decoded) {
      case GeoJSONObjectType.point:
        return Point.fromJson(json);
      case GeoJSONObjectType.multiPoint:
        return MultiPoint.fromJson(json);
      case GeoJSONObjectType.lineString:
        return LineString.fromJson(json);
      case GeoJSONObjectType.multiLineString:
        return MultiLineString.fromJson(json);
      case GeoJSONObjectType.polygon:
        return Polygon.fromJson(json);
      case GeoJSONObjectType.multiPolygon:
        return MultiPolygon.fromJson(json);
      case GeoJSONObjectType.geometryCollection:
        throw Exception(
            'This implementation does not support nested GeometryCollections');
      default:
        throw Exception('${json['type']} is not a valid GeoJSON type');
    }
  }

  @override
  GeometryType<T> clone();
}

/// Point, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.2
@JsonSerializable(explicitToJson: true)
class Point extends GeometryType<Position> {
  Point({BBox? bbox, required Position coordinates})
      : super.withType(coordinates, GeoJSONObjectType.point, bbox: bbox);

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  @override
  Map<String, dynamic> toJson() => super.serialize(_$PointToJson(this));

  @override
  Point clone() => Point(coordinates: coordinates.clone(), bbox: bbox?.clone());

  @override
  int get hashCode => Object.hashAll([
        type,
        ...coordinates,
        if (bbox != null) ...bbox!,
      ]);

  @override
  bool operator ==(Object other) =>
      other is Point ? coordinates == other.coordinates : false;
}

/// MultiPoint, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.3
@JsonSerializable(explicitToJson: true)
class MultiPoint extends GeometryType<List<Position>> {
  MultiPoint({BBox? bbox, List<Position> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectType.multiPoint, bbox: bbox);

  factory MultiPoint.fromJson(Map<String, dynamic> json) =>
      _$MultiPointFromJson(json);

  MultiPoint.fromPoints({BBox? bbox, required List<Point> points})
      : assert(points.length >= 2),
        super.withType(points.map((e) => e.coordinates).toList(),
            GeoJSONObjectType.multiPoint,
            bbox: bbox);

  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPointToJson(this));

  @override
  MultiPoint clone() => MultiPoint(
        coordinates: coordinates.map((e) => e.clone()).toList(),
        bbox: bbox?.clone(),
      );
}

/// LineString, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.4
@JsonSerializable(explicitToJson: true)
class LineString extends GeometryType<List<Position>> {
  LineString({BBox? bbox, List<Position> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectType.lineString, bbox: bbox);

  factory LineString.fromJson(Map<String, dynamic> json) =>
      _$LineStringFromJson(json);

  LineString.fromPoints({BBox? bbox, required List<Point> points})
      : assert(points.length >= 2),
        super.withType(points.map((e) => e.coordinates).toList(),
            GeoJSONObjectType.lineString,
            bbox: bbox);

  @override
  Map<String, dynamic> toJson() => super.serialize(_$LineStringToJson(this));

  @override
  LineString clone() => LineString(
      coordinates: coordinates.map((e) => e.clone()).toList(),
      bbox: bbox?.clone());
}

/// MultiLineString, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.5
@JsonSerializable(explicitToJson: true)
class MultiLineString extends GeometryType<List<List<Position>>> {
  MultiLineString({BBox? bbox, List<List<Position>> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectType.multiLineString,
            bbox: bbox);

  factory MultiLineString.fromJson(Map<String, dynamic> json) =>
      _$MultiLineStringFromJson(json);

  MultiLineString.fromLineStrings(
      {BBox? bbox, required List<LineString> lineStrings})
      : assert(lineStrings.length >= 2),
        super.withType(lineStrings.map((e) => e.coordinates).toList(),
            GeoJSONObjectType.multiLineString,
            bbox: bbox);

  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$MultiLineStringToJson(this));

  @override
  MultiLineString clone() => MultiLineString(
        coordinates:
            coordinates.map((e) => e.map((e) => e.clone()).toList()).toList(),
        bbox: bbox?.clone(),
      );
}

/// Polygon, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.6
@JsonSerializable(explicitToJson: true)
class Polygon extends GeometryType<List<List<Position>>> {
  Polygon({BBox? bbox, List<List<Position>> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectType.polygon, bbox: bbox);

  factory Polygon.fromJson(Map<String, dynamic> json) =>
      _$PolygonFromJson(json);

  Polygon.fromPoints({BBox? bbox, required List<List<Point>> points})
      : assert(points.expand((list) => list).length >= 3),
        super.withType(
            points.map((e) => e.map((e) => e.coordinates).toList()).toList(),
            GeoJSONObjectType.polygon,
            bbox: bbox);

  @override
  Map<String, dynamic> toJson() => super.serialize(_$PolygonToJson(this));

  @override
  Polygon clone() => Polygon(
        coordinates:
            coordinates.map((e) => e.map((e) => e.clone()).toList()).toList(),
        bbox: bbox?.clone(),
      );
}

/// MultiPolygon, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.7
@JsonSerializable(explicitToJson: true)
class MultiPolygon extends GeometryType<List<List<List<Position>>>> {
  MultiPolygon({BBox? bbox, List<List<List<Position>>> coordinates = const []})
      : super.withType(coordinates, GeoJSONObjectType.multiPolygon, bbox: bbox);

  factory MultiPolygon.fromJson(Map<String, dynamic> json) =>
      _$MultiPolygonFromJson(json);

  MultiPolygon.fromPolygons({BBox? bbox, required List<Polygon> polygons})
      : assert(polygons.length >= 2),
        super.withType(polygons.map((e) => e.coordinates).toList(),
            GeoJSONObjectType.multiPolygon,
            bbox: bbox);

  @override
  Map<String, dynamic> toJson() => super.serialize(_$MultiPolygonToJson(this));

  @override
  MultiPolygon clone() => MultiPolygon(
        coordinates: coordinates
            .map((e) => e.map((e) => e.map((e) => e.clone()).toList()).toList())
            .toList(),
        bbox: bbox?.clone(),
      );
}

/// GeometryCollection, as specified here https://tools.ietf.org/html/rfc7946#section-3.1.8
@JsonSerializable(explicitToJson: true, createFactory: false)
class GeometryCollection extends GeometryObject {
  List<GeometryType> geometries;

  GeometryCollection({BBox? bbox, this.geometries = const []})
      : super.withType(GeoJSONObjectType.geometryCollection, bbox: bbox);

  factory GeometryCollection.fromJson(Map<String, dynamic> json) =>
      GeometryCollection(
        bbox: json['bbox'] == null
            ? null
            : BBox.fromJson(
                (json['bbox'] as List).map((e) => e as num).toList(),
              ),
        geometries: (json['geometries'] as List?)
                ?.map((e) => GeometryType.deserialize(e))
                .toList() ??
            const [],
      );

  @override
  Map<String, dynamic> toJson() =>
      super.serialize(_$GeometryCollectionToJson(this));

  @override
  GeometryCollection clone() => GeometryCollection(
        geometries: geometries.map((e) => e.clone()).toList(),
        bbox: bbox?.clone(),
      );
}

/// Feature, as specified here https://tools.ietf.org/html/rfc7946#section-3.2
class Feature<T extends GeometryObject> extends GeoJSONObject {
  dynamic id;
  Map<String, dynamic>? properties;
  T? geometry;
  Map<String, dynamic> fields;

  Feature({
    BBox? bbox,
    this.id,
    this.properties = const {},
    this.geometry,
    this.fields = const {},
  }) : super.withType(GeoJSONObjectType.feature, bbox: bbox);

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        id: json['id'],
        geometry: json['geometry'] == null
            ? null
            : GeometryObject.deserialize(json['geometry']) as T,
        properties: json['properties'],
        bbox: json['bbox'] == null
            ? null
            : BBox.fromJson(
                (json['bbox'] as List).map((e) => e as num).toList()),
        fields: Map.fromEntries(
          json.entries.where(
            (el) =>
                el.key != 'geometry' &&
                el.key != 'properties' &&
                el.key != 'id',
          ),
        ),
      );

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
        return fields[key];
    }
  }

  @override
  int get hashCode => Object.hash(type, id);

  @override
  bool operator ==(Object other) => other is Feature ? id == other.id : false;

  @override
  Map<String, dynamic> toJson() => super.serialize({
        'id': id,
        'geometry': geometry!.toJson(),
        'properties': properties,
        ...fields,
      });

  @override
  Feature<T> clone() => Feature<T>(
        geometry: geometry?.clone() as T?,
        bbox: bbox?.clone(),
        fields: Map.of(fields),
        properties: Map.of(properties ?? {}),
        id: id,
      );
}

/// FeatureCollection, as specified here https://tools.ietf.org/html/rfc7946#section-3.3
class FeatureCollection<T extends GeometryObject> extends GeoJSONObject {
  List<Feature<T>> features;

  FeatureCollection({BBox? bbox, this.features = const []})
      : super.withType(GeoJSONObjectType.featureCollection, bbox: bbox);

  factory FeatureCollection.fromJson(Map<String, dynamic> json) =>
      FeatureCollection(
        bbox: json['bbox'] == null
            ? null
            : BBox.fromJson(
                (json['bbox'] as List).map((e) => e as num).toList()),
        features: (json['features'] as List<dynamic>?)
                ?.map((e) => Feature<T>.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  @override
  Map<String, dynamic> toJson() => super.serialize(<String, dynamic>{
        'features': features.map((e) => e.toJson()).toList(),
        'bbox': bbox?.toJson(),
      });

  @override
  FeatureCollection<T> clone() => FeatureCollection(
        features: features.map((e) => e.clone()).toList(),
        bbox: bbox?.clone(),
      );
}
