// ignore_for_file: library_private_types_in_public_api, unused_import

import 'dart:math';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gojo_renthub/mapService/bloc/map_bloc.dart';
import 'package:gojo_renthub/mapService/component/lower_button1.dart';
import 'package:gojo_renthub/mapService/component/marker_icon.dart';
import 'package:gojo_renthub/mapService/component/select_themes_bottom_sheet.dart';
import 'package:gojo_renthub/mapService/mapthemes/map_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as devtool show log;

import 'package:loading_animation_widget/loading_animation_widget.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  List<LatLng> coordinates = [];
  late final List<MarkerData> _customMarkers = [];
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  Position? position;

  final List<dynamic> _mapThemes = MapTheme.mapThemes;
  int _selectedMapThemes = 0;

  @override
  void initState() {
    coordinates = generateRandomLatLngs(10, 9.0182, 9.0292, 38.7515, 38.7525);
    markerCreator();
    super.initState();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  void markerCreator() {
    for (var i = 0; i < coordinates.length; i++) {
      _customMarkers.add(MarkerData(
          marker: Marker(
            markerId: MarkerId(i.toString()),
            position: coordinates[i],
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 130,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                'https://thumbs.dreamstime.com/b/america-middle-class-home-nice-dream-small-town-near-portland-oregon-usa-72283036.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "America middle class home",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Nice dream home of middle class in a small town near Portland, Oregon, USA.",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          MaterialButton(
                            onPressed: () {},
                            elevation: 0,
                            height: 40,
                            minWidth: double.infinity,
                            color: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Text(
                              "See details",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5.0,
                      left: 5.0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _customInfoWindowController.hideInfoWindow!();
                        },
                      ),
                    ),
                  ],
                ),
                coordinates[i],
              );
            },
          ),
          child: customMarker('${i * 1000}')));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapThemeSelected) {
            selectThemeBottomSheet(
              context: context,
              mapThemes: _mapThemes,
            );
          }
          if (state is MapStyleLoaded) {
            _selectedMapThemes = state.selectedStyle;
          }
        
        },
        builder: (context, state) {
          if (state is MapLoaded) {
            position = state.currentPosition;
            return Stack(
              children: [
                CustomGoogleMapMarkerBuilder(
                  customMarkers: _customMarkers,
                  builder: (context, markers) {
                    if (markers == null) {
                      return Center(
                          child: LoadingAnimationWidget.inkDrop(
                              color: Colors.lightBlueAccent, size: 50));
                    }

                    return GoogleMap(
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                      padding: const EdgeInsets.only(top: 300),
                      style: _mapThemes[_selectedMapThemes]['style'],
                      initialCameraPosition: CameraPosition(
                          zoom: 12,
                          target: LatLng(state.currentPosition.latitude,
                              state.currentPosition.longitude)),
                      markers: markers,
                      onCameraMove: (position) {
                        _customInfoWindowController.onCameraMove!();
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        _customInfoWindowController.googleMapController =
                            controller;
                      },
                    );
                  },
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.8,
                  offset: 60.0,
                ),
                LowerButton1(controller: _controller),
                Positioned(
                  bottom: 160,
                  right: 15,
                  child: Container(
                      width: 35,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              context
                                  .read<MapBloc>()
                                  .add(MapThemeLayoutSelected());
                            },
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.layers_rounded, size: 25),
                          )
                        ],
                      )),
                )
              ],
            );
          } else {
            return Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: Colors.lightBlueAccent, size: 50));
          }
        },
      ),
    );
  }
}

List<LatLng> generateRandomLatLngs(
    int count, double minLat, double maxLat, double minLng, double maxLng) {
  List<LatLng> coordinates = [];
  Random random = Random();
  for (int i = 0; i < count; i++) {
    double latitude = minLat + random.nextDouble() * (maxLat - minLat);
    double longitude = minLng + random.nextDouble() * (maxLng - minLng);
    coordinates.add(LatLng(latitude, longitude));
  }
  return coordinates;
}
