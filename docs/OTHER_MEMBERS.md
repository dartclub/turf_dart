# GeoJSON "Other Members" Support in TurfDart

## Overview

In accordance with [RFC 7946 (The GeoJSON Format)](https://datatracker.ietf.org/doc/html/rfc7946), TurfDart now supports "other members" in GeoJSON objects. The specification states:

> "A GeoJSON object MAY have 'other members'. Implementations MUST NOT interpret foreign members as having any meaning unless part of an extension or profile."

This document explains how to use the "other members" support in TurfDart.

## Features

- Store and retrieve custom fields in any GeoJSON object
- Preserve custom fields when serializing to JSON
- Preserve custom fields when cloning GeoJSON objects
- Extract custom fields from JSON during deserialization

## Usage

### Adding Custom Fields to GeoJSON Objects

```dart
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

// Create a GeoJSON object
final point = Point(coordinates: Position(10, 20));

// Add custom fields
point.setOtherMembers({
  'custom_field': 'custom_value',
  'metadata': {'source': 'my_data_source', 'date': '2025-04-18'}
});
```

### Retrieving Custom Fields

```dart
// Get all custom fields
final otherMembers = point.otherMembers;
print(otherMembers); // {'custom_field': 'custom_value', 'metadata': {...}}

// Access specific custom fields
final customField = point.otherMembers['custom_field'];
final metadataSource = point.otherMembers['metadata']['source'];
```

### Serializing with Custom Fields

```dart
// Convert to JSON including custom fields
final json = point.toJsonWithOtherMembers();
// Result: 
// {
//   'type': 'Point',
//   'coordinates': [10, 20],
//   'custom_field': 'custom_value',
//   'metadata': {'source': 'my_data_source', 'date': '2025-04-18'}
// }
```

### Cloning with Custom Fields

```dart
// Clone the object while preserving custom fields
final clonedPoint = point.clonePreservingOtherMembers<Point>();
print(clonedPoint.otherMembers); // Same custom fields as original
```

### Creating Modified Copies While Preserving Custom Fields

```dart
// Create a Feature with custom fields
final feature = Feature(
  geometry: Point(coordinates: Position(10, 20)),
  properties: {'name': 'Original Point'},
);
feature.setOtherMembers({'custom_field': 'custom_value'});

// Create a new Feature with updated properties, preserving custom fields
final modifiedFeature = feature.copyWithPreservingOtherMembers<Point>(
  properties: {'name': 'Modified Point'},
);
print(modifiedFeature.otherMembers['custom_field']); // 'custom_value'

// Create a new FeatureCollection with updated features, preserving custom fields
final featureCollection = FeatureCollection(features: [feature]);
featureCollection.setOtherMembers({'source': 'test_data'});

final updatedCollection = featureCollection.copyWithPreservingOtherMembers<Point>(
  features: [modifiedFeature],
);
print(updatedCollection.otherMembers['source']); // 'test_data'

// Create a new geometry while preserving custom fields
final geometry = Point(coordinates: Position(10, 20));
geometry.setOtherMembers({'category': 'landmark'});

final modifiedGeometry = geometry.copyWithPreservingOtherMembers() as Point;
print(modifiedGeometry.otherMembers['category']); // 'landmark'
```

### Deserializing from JSON with Custom Fields

```dart
// Parse Feature with custom fields from JSON
final featureJson = {
  'type': 'Feature',
  'geometry': {'type': 'Point', 'coordinates': [10, 20]},
  'properties': {'name': 'Example Point'},
  'custom_field': 'custom_value'
};

final feature = FeatureOtherMembersExtension.fromJsonWithOtherMembers(featureJson);
print(feature.otherMembers['custom_field']); // 'custom_value'

// Parse FeatureCollection with custom fields from JSON
final featureCollectionJson = {
  'type': 'FeatureCollection',
  'features': [...],
  'custom_field': 'custom_value'
};

final collection = FeatureCollectionOtherMembersExtension.fromJsonWithOtherMembers(featureCollectionJson);
print(collection.otherMembers['custom_field']); // 'custom_value'

// Parse GeometryObject with custom fields from JSON
final geometryJson = {
  'type': 'Point',
  'coordinates': [10, 20],
  'custom_field': 'custom_value'
};

final geometry = GeometryObjectOtherMembersExtension.fromJsonWithOtherMembers(geometryJson);
print(geometry.otherMembers['custom_field']); // 'custom_value'
```

## Implementation Notes

- Custom fields are stored in memory using Expando to safely attach data to each object without leaks
- The extension approach was chosen to avoid modifying the core GeoJSON classes defined in the geotypes package
- This implementation fully complies with RFC 7946's recommendations for handling "other members"

## Limitations

- Custom fields are stored in memory and not persisted across application restarts
- Care should be taken to prevent memory leaks by not storing too many objects with large custom fields
