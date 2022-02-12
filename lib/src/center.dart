import 'package:turf/helpers.dart';

List<double> center(BBox bBox) {
  return [(bBox.lat1 + bBox.lat2) / 2, (bBox.lng1 + bBox.lng2) / 2];
}
