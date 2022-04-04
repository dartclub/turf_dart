import 'package:turf/helpers.dart';

Position center(BBox bBox) {
  return Position.named(lat: (bBox.lat1 + bBox.lat2) / 2, lng: (bBox.lng1 + bBox.lng2) / 2);
}
