# Turf Helpers Examples

This directory contains examples demonstrating the utility functions in the `helpers.dart` file of the turf_dart library.

## Files in this Directory

1. **helpers_example.dart**: Practical examples of using the helpers functions with explanations and output
2. **helpers_visualization.geojson**: Visual demonstration of the helpers functions for viewing in a GeoJSON viewer
3. **test_helpers.dart**: Simple test functions that exercise each major function in the helpers.dart file

## Functionality Demonstrated

### Unit Conversions
- Convert between different length units (kilometers, miles, meters, etc.)
- Convert between different area units
- Convert between radians, degrees, and real-world units

### Angle Conversions
- Convert between degrees and radians
- Convert bearings to azimuths (normalized angles)

### Rounding Functions
- Round numbers to specific precision levels

## Running the Examples

To run the example code and see the output:

```bash
dart test/examples/helpers/helpers_example.dart
```

## Visualization

The `helpers_visualization.geojson` file can be viewed in any GeoJSON viewer to see visual examples of:

1. **Distance Conversion**: Circle with 10km radius showing conversion between degrees and kilometers
2. **Bearing Example**: Line and points showing bearing/azimuth concepts
3. **Angle Conversion**: Points at different angles (0°, 90°, 180°, 270°) around a circle
4. **Area Conversion**: Square with 10km² area

## Helper Functions Reference

| Function | Description |
|----------|-------------|
| `radiansToLength(radians, unit)` | Convert radians to real-world distance units |
| `lengthToRadians(distance, unit)` | Convert real-world distance to radians |
| `lengthToDegrees(distance, unit)` | Convert real-world distance to degrees |
| `bearingToAzimuth(bearing)` | Convert any bearing angle to standard azimuth (0-360°) |
| `radiansToDegrees(radians)` | Convert radians to degrees |
| `degreesToRadians(degrees)` | Convert degrees to radians |
| `convertLength(length, fromUnit, toUnit)` | Convert length between different units |
| `convertArea(area, fromUnit, toUnit)` | Convert area between different units |
| `round(value, precision)` | Round number to specified precision |
| `toMercator(coord)` | Convert WGS84 coordinates [lon, lat] to Web Mercator [x, y] |
| `toWGS84(coord)` | Convert Web Mercator coordinates [x, y] to WGS84 [lon, lat] |
| `convertCoordinates(coord, fromSystem, toSystem)` | Convert coordinates between different systems |
