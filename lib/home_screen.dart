import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});


  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData? currentLocation;
  LocationData? firstLocation;
  StreamSubscription? _locationSubscription ;
  List<LatLng> polylineCoordinates = [];


  void polylineLatLong(){
    var polyline = [ currentLocation!.latitude!, currentLocation!.latitude!];
    print(polyline);
  }



  @override
  void initState() {
    getCurrentLocation();
    listenLocation();
    initialize();
    super.initState();
  }
  void initialize(){
    Location.instance.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      interval: 3000,
    );
  }

  void listenLocation() {
    _locationSubscription =
        Location.instance.onLocationChanged.listen((listenLocation) {
          if (listenLocation != currentLocation) {
            currentLocation = listenLocation;
            if (mounted) {
              setState(() {});
            }
            final LatLng newPoint =
            LatLng(listenLocation.latitude!, listenLocation.longitude!);
            if (polylineCoordinates.isEmpty ||
                polylineCoordinates.last != newPoint) {
              polylineCoordinates.add(newPoint);
            }
          }
        });
  }

  void getCurrentLocation() async {
    await Location.instance.hasPermission().then((requestPermission) {
      print(requestPermission);
    });

    Location.instance.getLocation().then((location) {
      currentLocation = location;
      if (firstLocation == null) {
        firstLocation = location;
        polylineCoordinates.add(
          LatLng(firstLocation!.latitude!, firstLocation!.longitude!),
        );
      }
    });
    if(mounted){
      setState(() {});
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RealTime Location"),
      ),
      body: currentLocation == null
          ? const Center(
        child: Text("Loading"),
      )
          : GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: CameraPosition(
            zoom: 14,
            bearing: 30,
            tilt: 15,
            target: LatLng(
                currentLocation!.latitude!, currentLocation!.longitude!)),
        markers: <Marker>{
          Marker(
              markerId: const MarkerId("current Location"),
              position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                  title: "My current Location ${currentLocation!.latitude!},${currentLocation!.longitude!}"

              ))
        },
        polylines: <Polyline>{
          Polyline(
            polylineId: const PolylineId("route"),
            width: 6,
            color: Colors.deepOrange,
            points: polylineCoordinates,
          ),
        },
      ),
    );
  }
  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}