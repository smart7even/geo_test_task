import 'dart:math';

import 'package:geo_test_task/models/coordinates.dart';
import 'package:geo_test_task/models/pixel_coordinates.dart';
import 'package:geo_test_task/models/tile.dart';

class GeoToTileConverter {
  PixelCoordintes _convertToPixelCoordinates(
      Coordinates coordinates, int zoom) {
    double eccentricity = 0.0818191908426;

    double rho = pow(2, zoom + 8) / 2;
    double beta = coordinates.lat * pi / 180;
    double phi =
        (1 - eccentricity * sin(beta)) / (1 + eccentricity * sin(beta));
    double theta = tan(pi / 4 + beta / 2) * pow(phi, eccentricity / 2);

    double x = rho * (1 + coordinates.long / 180);
    double y = rho * (1 - log(theta) / pi);

    return PixelCoordintes(x, y, zoom);
  }

  Tile convert(Coordinates coordinates, int zoom) {
    var pixelCoordinates = _convertToPixelCoordinates(coordinates, zoom);

    return Tile((pixelCoordinates.x / 256).floor(),
        (pixelCoordinates.y / 256).floor(), zoom);
  }
}
