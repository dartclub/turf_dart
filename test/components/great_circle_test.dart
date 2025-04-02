import 'package:turf/great_circle.dart';
import 'package:test/test.dart';

void main() {
  //First test - simple coordinates

  List<double> start = [-90, 0];
  List<double> end = [-80,0];

  List<List<double>> resultsFirstTest1 = [[-90.0, 0.0], [-88.0,0.0], [-86.0,0.0], [-84.0, 0.0], [-82.0, 0.0],[-80.0, 0.0]];
  List<List<double>> resultsFirstTest2 = [[-90.0, 0.0], [-89.0,0.0], [-88.0,0.0], [-87.0, 0.0], [-86.0, 0.0],[-85.0,0.0], [-84.0,0.0], [-83.0, 0.0], [-82.0, 0.0],[-81.0, 0.0], [-80.0, 0.0]];
  
  // Second test - intermediate coordiantes (non-straight lines)
  List<double> start2 = [48, -122];
  List<double> end2 = [39, -77];

  List<List<double>> resultsSecondTest1 = [[48.0, -122.0], [43.5, -99.5], [39.0, -77.0]];
  List<List<double>> resultsSecondTest2 = [[]];



  // Third test - complex coordinates (crossing anti-meridian)

  List<double> start3 = [-21, 143];
  List<double> end3 = [41, -140];
  
  test('Great circle simple tests:', () {
    expect(greatCircle(start, end, npoints: 5), resultsFirstTest1);
    expect(greatCircle(start, end, npoints: 10), resultsFirstTest2);
  });


}