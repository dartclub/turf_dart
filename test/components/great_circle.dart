import 'package:turf/great_circle.dart';

void main() {
  
  List<double> start = [-122, 48];
  List<double> end = [-77, 39];

  List<List<double>> result = greatCircle(start, end, npoints: 10);
  print(result);
}