import 'geojson.dart';

Point? intersects(LineString line1, LineString line2) {
  if (line1.coordinates.length != 2) {
    throw Exception('line1 must only contain 2 coordinates');
  }

  if (line2.coordinates.length != 2) {
    throw Exception('line2 must only contain 2 coordinates');
  }

  final x1 = line1.coordinates[0][0]!;
  final y1 = line1.coordinates[0][1]!;
  final x2 = line1.coordinates[1][0]!;
  final y2 = line1.coordinates[1][1]!;
  final x3 = line2.coordinates[0][0]!;
  final y3 = line2.coordinates[0][1]!;
  final x4 = line2.coordinates[1][0]!;
  final y4 = line2.coordinates[1][1]!;

  final denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);

  if (denom == 0) {
    return null;
  }

  final numeA = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
  final numeB = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);

  final uA = numeA / denom;
  final uB = numeB / denom;

  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    final x = x1 + uA * (x2 - x1);
    final y = y1 + uA * (y2 - y1);

    return Point(coordinates: Position.named(lng: x, lat: y));
  }

  return null;
}
