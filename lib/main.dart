import 'package:flutter/material.dart';
import 'package:geo_test_task/models/coordinates.dart';
import 'package:geo_test_task/models/tile.dart';
import 'package:geo_test_task/service/geo_to_tile_converter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking lots',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Parking lots'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  Tile? tile;

  final latitudeController = TextEditingController(text: '55.760031');
  final longitudeController = TextEditingController(text: '37.645363');
  final zoomController = TextEditingController(text: '19');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    zoomController.dispose();
    super.dispose();
  }

  void setTile(Coordinates coords, int zoom) {
    var converter = GeoToTileConverter();
    Tile newTile = converter.convert(coords, zoom);
    print('${newTile.x} ${newTile.y} ${newTile.zoom}');

    setState(() {
      tile = newTile;
    });
  }

  String buildTileURL(Tile tile) {
    return 'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=${tile.x}&y=${tile.y}&z=${tile.zoom}&scale=1&lang=ru_RU';
  }

  @override
  Widget build(BuildContext context) {
    Tile? currentTile = tile;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: latitudeController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter latitude',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        String pleaseEnterLatitude =
                            'Please enter latitude (e.g 55.760031)';

                        if (value == null || value.isEmpty) {
                          return pleaseEnterLatitude;
                        }

                        double? latitude = double.tryParse(value);
                        if (latitude == null) {
                          return pleaseEnterLatitude;
                        }

                        if (!(latitude >= -90 && latitude <= 90)) {
                          return 'Latitude should be between -90 and 90';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: longitudeController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter longtitude',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        String pleaseEnterLongtitude =
                            'Please enter longtitude (e.g 37.645363)';

                        if (value == null || value.isEmpty) {
                          return pleaseEnterLongtitude;
                        }

                        double? latitude = double.tryParse(value);
                        if (latitude == null) {
                          return pleaseEnterLongtitude;
                        }

                        if (!(latitude >= -180 && latitude <= 180)) {
                          return 'Longtitude should be between -180 and 180';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: zoomController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter zoom',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        String pleaseEnterZoom = 'Please enter zoom (e.g 19)';

                        if (value == null || value.isEmpty) {
                          return pleaseEnterZoom;
                        }

                        int? zoom = int.tryParse(value);
                        if (zoom == null) {
                          return pleaseEnterZoom;
                        }

                        if (!(zoom >= 0 && zoom <= 20)) {
                          return 'Zoom should be between 0 and 20';
                        }

                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );

                          double latitude =
                              double.parse(latitudeController.text);
                          double longtitude =
                              double.parse(longitudeController.text);
                          int zoom = int.parse(zoomController.text);
                          Coordinates coords =
                              Coordinates(long: longtitude, lat: latitude);

                          setTile(coords, zoom);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: const Text('Show tile'),
                    ),
                  ],
                ),
              ),
            ),
            if (currentTile is Tile)
              Column(
                children: [
                  Center(
                    child: Image.network(
                      buildTileURL(currentTile),
                      errorBuilder: ((context, error, stackTrace) {
                        return const Text('There is no parking lots here');
                      }),
                    ),
                  ),
                  Text(
                      'X=${currentTile.x}, Y=${currentTile.y}, Z=${currentTile.zoom}')
                ],
              ),
          ],
        ),
      ),
    );
  }
}
