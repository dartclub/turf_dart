import 'package:turf/src/geojson.dart';
import 'package:turf/src/polygon_clipping/sweep_event.dart';

class PositionEvents extends Position {
  List<SweepEvent>? events;

  PositionEvents(
    double super.lng,
    double super.lat,
    this.events,
  );

  factory PositionEvents.fromPoint(Position point) {
    return PositionEvents(point.lng.toDouble(), point.lat.toDouble(), []);
  }
}
