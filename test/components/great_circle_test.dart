import 'package:turf/great_circle.dart';
import 'package:test/test.dart';

void main() {
  //First test - simple coordinates

  List<double> start = [-90, 0];
  List<double> end = [-80,0];

  List<List<double>> resultsFirstTest1 = [[-90.0, 0.0], [-88.0,0.0], [-86.0,0.0], [-84.0, 0.0], [-82.0, 0.0],[-80.0, 0.0]];
  List<List<double>> resultsFirstTest2 = [[-90.0, 0.0], [-89.0,0.0], [-88.0,0.0], [-87.0, 0.0], [-86.0, 0.0],[-85.0,0.0], [-84.0,0.0], [-83.0, 0.0], [-82.0, 0.0],[-81.0, 0.0], [-80.0, 0.0]];
  
  test('Great circle simple tests:', () {
    expect(greatCircle(start, end, npoints: 5), resultsFirstTest1);
    expect(greatCircle(start, end, npoints: 10), resultsFirstTest2);
  });
  
  // Second test - intermediate coordiantes (non-straight lines)
  List<double> start2 = [48, -122];
  List<double> end2 = [39, -77];

  List<List<double>> resultsSecondTest1 = [[48.0, -122.0], [45.75, -97.73], [39.0, -77.0]];
  List<List<double>> resultsSecondTest2 = [[48.0, -122.0], [47.52, -109.61], [45.75, -97.73], [42.85, -86.80], [39.0, -77.0]];


  test('Great circle intermediate tests:', () {
    expect(greatCircle(start2, end2, npoints: 2), resultsSecondTest1);
    expect(greatCircle(start2, end2, npoints: 4), resultsSecondTest2);
  });

  // Third test - complex coordinates (crossing anti-meridian)

  List<double> start3 = [-21, 143];
  List<double> end3 = [41, -140];

  List<List<double>> resultsThirdTest1 = [[-21.0, 143.0], [12.65, 176.68], [41, -140]];
  List<List<double>> resultsThirdTest2 = [[-21.0, 143.0], [-4.36, 160.22], [12.65, 176.68], [28.52, -164.56], [41, -140]];
  test('Great circle complex tests:', () {
    expect(greatCircle(start3, end3, npoints: 2), resultsThirdTest1);
    expect(greatCircle(start3, end3, npoints: 4), resultsThirdTest2);
  });
}