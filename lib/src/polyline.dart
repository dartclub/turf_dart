import 'dart:math' as math;

List<List<double>> decodePolyline(String polyline, {int precision = 5}) {
  var index = 0, lat = 0, lng = 0, shift = 0, result = 0, byte, factor = math.pow(10, precision);
  int latitudeChange;
  int longitudeChange;
  List<List<double>> coordinates = [];

  while (index < polyline.length) {
    byte = null;
    shift = 0;
    result = 0;

    do {
      byte = polyline.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    latitudeChange = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    shift = result = 0;

    do {
      byte = polyline.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    longitudeChange = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

    lat += latitudeChange;
    lng += longitudeChange;

    coordinates.add([(lat / factor).toDouble(), (lng / factor).toDouble()]);
  }

  return coordinates;
}
