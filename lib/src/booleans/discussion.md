
```

// booleanWithin(Multipoint, LineString) -> at least one point not at start or end.
// booleanWithin(Point, LineString) -> ignore Vertices.
// booleanWithin(Point, Polygon) -> ignore Vertices.
// booleanWithin(MultiPoint, LineString) -> at least one inner point.
// booleanWithin(MultiPoint, Polygon) -> at least one inner point.
// booleanWithin(LineString, LineString) -> no check if there is a inner point.
// booleanWithin(LineString, Polygon) -> at least one point of the line or one 
//    point between two point of the line is not on the boundary.
// booleanWithin(Polygon, Polygon) -> no check if there is a inner point.

// booleanWithin(LineString, Polygon): TurfJs seems to have an bug. When the last
// point of the line is outside of the polygon, the function returns true.
// turf-boolean-within -> isLineInPoly

```



https://geojson.io/#map=4.84/4.83/2.16


## Polygon is within polygon
file: examples/booleans/within/true/Polygon/Polygon/skip-PolygonIsWIthinPolygon.geojson

This test fails, because the bounding box of the first polygon is not complete within the second polygon. Both polygons share one point.
I'm not sure, if this is the expected behavior. Other within functions allow it if one geometry is on the border of another geometry, if 
