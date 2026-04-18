/// Configuration options for the polygonize algorithm
class PolygonizeConfig {
  /// Factor to detect significant gaps in X coordinate clustering
  /// A higher value makes the algorithm less likely to split features based on X coordinates
  final double gapFactorX;

  /// Factor to detect significant gaps in Y coordinate clustering
  /// A higher value makes the algorithm less likely to split features based on Y coordinates
  final double gapFactorY;

  /// Factor to detect significant distance gaps for hole detection
  /// A higher value makes the algorithm less likely to detect holes
  final double distanceFactorForHoles;

  /// Create a configuration for the polygonize algorithm
  const PolygonizeConfig({
    required this.gapFactorX,
    required this.gapFactorY,
    required this.distanceFactorForHoles,
  });
}
