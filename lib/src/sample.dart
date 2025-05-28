import 'dart:math';
import 'package:turf/turf.dart';

/// Returns a new [FeatureCollection] containing [num] randomly-selected features
/// from the input collection, **without replacement**.
///
/// Throws [ArgumentError] if:
/// * [fc] is `null`
/// * [num] is `null`, negative, or greater than `fc.features.length`
FeatureCollection<T> sample<T extends GeometryObject>(
  FeatureCollection<T> fc,
  int num, {
  Random? random,
}) {
  if (num < 0 || num > fc.features.length) {
    throw ArgumentError(
        'num must be between 0 and the number of features in the collection');
  }

  final rnd = random ?? Random();
  final shuffled = List<Feature<T>>.from(fc.features);

  // Partial Fisher-Yates: shuffle only the tail we need.
  for (var i = shuffled.length - 1; i >= shuffled.length - num; i--) {
    final j = rnd.nextInt(i + 1);
    final temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }

  final selected = shuffled.sublist(shuffled.length - num);
  return FeatureCollection<T>(features: selected);
}
