import 'dart:math';

import 'package:turf/src/polygon_clipping/sweep_event.dart';

class PointEvents extends Point {
  List<SweepEvent>? events;

  PointEvents(
    double super.x,
    double super.y,
    this.events,
  );

  factory PointEvents.fromPoint(Point point) {
    return PointEvents(point.x.toDouble(), point.y.toDouble(), []);
  }
}
