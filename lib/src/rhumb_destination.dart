import 'dart:math' as math;

import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';

///
/// Returns the destination [Point] having traveled the given distance along a Rhumb line from the
/// origin Point with the (variant) given bearing.
///
/// example:
/// ```dart
/// var properties = { 'foo': 'bar' };
/// var point = Feature(geometry: Point(coordinates: Position.of([-75.343, 39.984])));
///
/// final destinationPoint = rhumbDestination(
///                 feature.geometry!,
///                 dist,
///                 bearing,
///                 unit: Unit.meters,
///                 properties: feature.properties,
///               );
/// ```

Feature<Point> rhumbDestination(
  Point origin,
  num distance,
  num bearing, {
  Unit? unit = Unit.kilometers,
  Map<String, dynamic>? properties,
}) {
  unit ??= Unit.kilometers;

  final wasNegativeDistance = distance < 0;
  var distanceInMeters = convertLength(distance.abs(), unit, Unit.meters);
  if (wasNegativeDistance) distanceInMeters = -(distanceInMeters.abs());
  final coords = getCoord(origin);
  final destination =
      calculateRhumbDestination(coords, distanceInMeters, bearing);

  // compensate the crossing of the 180th meridian (https://macwright.org/2016/09/26/the-180th-meridian.html)
  // solution from https://github.com/mapbox/mapbox-gl-js/issues/3250#issuecomment-294887678
  final compensateLng = (destination.lng - coords.lng) > 180
      ? -360
      : (coords.lng - destination.lng) > 180
          ? 360
          : 0;

  return Feature<Point>(
      geometry: Point(
          coordinates:
              Position(destination.lng + compensateLng, destination.lat)));
}

Position calculateRhumbDestination(Position origin, num distance, num bearing,
    [num radius = earthRadius]) {
  final R = radius > 0 ? radius : earthRadius;
  final delta = distance / R;
  final lambda1 = (origin.lng * math.pi) / 180;
  final phi1 = degreesToRadians(origin.lat);
  final theta = degreesToRadians(bearing);

  final dPhi = delta * math.cos(theta);
  var phi2 = phi1 + dPhi;

  // check for some daft bugger going past the pole, normalize latitude if so
  if (phi2.abs() > math.pi / 2) {
    phi2 = phi2 > 0 ? math.pi - phi2 : -math.pi - phi2;
  }

  final dPsi = math
      .log(math.tan(phi2 / 2 + math.pi / 4) / math.tan(phi1 / 2 + math.pi / 4));
  // E-W course becomes ill-conditioned with 0/0
  final q = dPsi.abs() > 10e-12 ? dPhi / dPsi : math.cos(phi1);

  final dLambda = (delta * math.sin(theta)) / q;
  final lambda2 = lambda1 + dLambda;

  // normalize to −180..+180°
  final lng = (((lambda2 * 180) / math.pi + 540) % 360) - 180;
  final lat = (phi2 * 180) / math.pi;

  return Position(lng, lat);
}
