import 'dart:collection';
import 'dart:math';

/// A class for rounding floating-point coordinates to avoid floating-point problems.
class PtRounder {
  late CoordRounder xRounder;
  late CoordRounder yRounder;

  /// Constructor for PtRounder.
  PtRounder() {
    reset();
  }

  /// Resets the PtRounder by creating new instances of CoordRounder.
  void reset() {
    xRounder = CoordRounder();
    yRounder = CoordRounder();
  }

  /// Rounds the input x and y coordinates using CoordRounder instances.
  Point round(num x, num y) {
    return Point(
      xRounder.round(x),
      xRounder.round(y),
    );
  }
}

/// A class for rounding individual coordinates.
class CoordRounder {
  late SplayTreeMap<num, num> tree;

  /// Constructor for CoordRounder.
  CoordRounder() {
    tree = SplayTreeMap<num, num>();
    // Preseed with 0 so we don't end up with values < epsilon.
    round(0);
  }

  /// Rounds the input coordinate and adds it to the tree.
  ///
  /// Returns the rounded value of the coordinate.
  num round(num coord) {
    final node = tree.putIfAbsent(coord, () => coord);

    final prevKey = nodeKeyBefore(coord);
    final prevNode = prevKey != null ? tree[prevKey] : null;

    if (prevNode != null && node == prevNode) {
      tree.remove(coord);
      return prevNode;
    }

    final nextKey = nodeKeyAfter(coord);
    final nextNode = nextKey != null ? tree[nextKey] : null;

    if (nextNode != null && node == nextNode) {
      tree.remove(coord);
      return nextNode;
    }

    return coord;
  }

  /// Finds the key of the node before the given key in the tree.
  ///
  /// Returns the key of the previous node.
  num? nodeKeyBefore(num key) {
    final lowerKey = tree.keys.firstWhere((k) => k < key, orElse: () => key);
    return lowerKey != key ? lowerKey : null;
  }

  /// Finds the key of the node after the given key in the tree.
  ///
  /// Returns the key of the next node.
  num? nodeKeyAfter(num key) {
    final upperKey = tree.keys.firstWhere((k) => k > key, orElse: () => key);
    return upperKey != key ? upperKey : null;
  }
}

/// Global instance of PtRounder available for use.
final rounder = PtRounder();
