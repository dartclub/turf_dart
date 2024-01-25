import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/length.dart';

void main() {
  test('length - in meters', () {
    final len = length(line, Unit.meters);
    expect(len.round(), equals(254));
  });
  test('length - default unit (km)', () {
    final len = length(line);
    expect((len * 1000).round(), equals(254));
  });
}

final start = Position.named(
  lat: 55.7090430186194,
  lng: 13.184645393920405,
);
final via = Position.named(
  lat: 55.70901279569489,
  lng: 13.185546616182755,
);
final end = Position.named(
  lat: 55.70764669578079,
  lng: 13.187563637197076,
);
final line = Feature<LineString>(
  geometry: LineString(
    coordinates: [
      start,
      via,
      end,
    ],
  ),
);