// A List of builders that are similar to the way TurfJs creates GeoJSON
// objects. The idea is to make it easier to port JavaScript tests to Dart.
import 'package:turf/turf.dart';

Feature<Point> point(List<double> coordinates) {
  return Feature<Point>(
    geometry: Point(
      coordinates: Position.of(coordinates),
    ),
  );
}

Feature<MultiPoint> multiPoint(List<List<double>> coordinates) {
  return Feature<MultiPoint>(
    geometry: MultiPoint(
      coordinates:
          coordinates.map((e) => Position.of(e)).toList(growable: false),
    ),
  );
}

Position position(List<double> coordinates) {
  return Position.of(coordinates);
}

List<Position> positions(List<List<double>> coordinates) {
  return coordinates.map((e) => position(e)).toList(growable: false);
}

Feature<LineString> lineString(List<List<double>> coordinates, {dynamic id}) {
  return Feature(
    id: id,
    geometry: LineString(coordinates: positions(coordinates)),
  );
}

Feature<MultiLineString> multiLineString(
    List<List<List<double>>?> coordinates) {
  return Feature(
    geometry: MultiLineString(
        coordinates: coordinates
            .map((element) => positions(element!))
            .toList(growable: false)),
  );
}

Feature<Polygon> polygon(List<List<List<double>>> coordinates) {
  return Feature(
    geometry: Polygon(
        coordinates: coordinates
            .map((element) => positions(element))
            .toList(growable: false)),
  );
}

Feature<MultiPolygon> multiPolygon(
    List<List<List<List<double>>>?> coordinates) {
  return Feature(
    geometry: MultiPolygon(
        coordinates: coordinates
            .map((element) =>
                element!.map((e) => positions(e)).toList(growable: false))
            .toList(growable: false)),
  );
}

FeatureCollection featureCollection<T extends GeometryObject>(
    [List<Feature<T>> features = const []]) {
  return FeatureCollection<T>(features: features);
}
