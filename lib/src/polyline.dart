import 'dart:math' as math;

import 'package:turf/helpers.dart';

/// Based off of [the offical Google document](https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
/// Some parts from [this implementation](http://facstaff.unca.edu/mcmcclur/GoogleMaps/EncodePolyline/PolylineEncoder.js)
/// by [Mark McClure](http://facstaff.unca.edu/mcmcclur/)
class Polyline {
  static String _encode(num current, num previous, num factor) {
    current = _py2Round(current * factor);
    previous = _py2Round(previous * factor);
    var coordinate = (current - previous).toInt();
    coordinate <<= 1;
    if (current - previous < 0) {
      coordinate = ~coordinate;
    }
    var output = '';
    while (coordinate >= 0x20) {
      output += String.fromCharCode((0x20 | (coordinate & 0x1f)) + 63);
      coordinate >>= 5;
    }
    output += String.fromCharCode(coordinate + 63);

    return output;
  }

  static int _py2Round(num value) {
    // Google's polyline algorithm uses the same rounding strategy as Python 2, which is different from JS for negative values
    return (value.abs() + 0.5).floor() * (value >= 0 ? 1 : -1);
  }

  /// Decodes a Polyline to a [List<Position>].
  /// This is adapted from the implementation in Project-OSRM.
  /// See https://github.com/Project-OSRM/osrm-frontend/blob/master/WebContent/routing/OSRM.RoutingGeometry.js
  static List<Position> decode(String polyline, {int precision = 5}) {
    var index = 0,
        lat = 0,
        lng = 0,
        shift = 0,
        result = 0,
        factor = math.pow(10, precision);
    int? byte;
    late int latitudeChange;
    late int longitudeChange;
    List<Position> coordinates = [];

    // Coordinates have variable length when encoded, so just keep
    // track of whether we've hit the end of the string. In each
    // loop iteration, a single coordinate is decoded.
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

      coordinates.add(
        Position.named(
            lng: (lng / factor).toDouble(), lat: (lat / factor).toDouble()),
      );
    }

    return coordinates;
  }

  /// Encodes the given [List<Position>] to a polyline, a [String].
  static String encode(List<Position> coordinates, {int? precision}) {
    if (coordinates.isEmpty) {
      return '';
    }

    var factor = math.pow(10, precision ?? 5),
        output = _encode(coordinates[0].lat, 0, factor) +
            _encode(coordinates[0].lng, 0, factor);

    for (var i = 1; i < coordinates.length; i++) {
      var a = coordinates[i], b = coordinates[i - 1];
      output += _encode(a.lat, b.lat, factor);
      output += _encode(a.lng, b.lng, factor);
    }

    return output;
  }
}
