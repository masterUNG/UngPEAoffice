import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ungpeaofficer/utility/dialog.dart';
import 'package:ungpeaofficer/widgets/show_progress.dart';

class ShowMap extends StatefulWidget {
  @override
  _ShowMapState createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  bool locationServiceEnble, load = true, deniedBool = false;
  LocationPermission locationPermission;
  double lat, lng;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findLatLng();
    // lat = 13.674244475527557;
    // lng = 100.6065846001858;
  }

  Future<Null> findLatLng() async {
    await Geolocator.isLocationServiceEnabled().then((value) async {
      setState(() {
        load = false;
      });

      locationServiceEnble = value;

      if (locationServiceEnble) {
        locationPermission = await Geolocator.checkPermission();
        print('### your permission ==>>> ${locationPermission.toString()}');

        if (locationPermission == LocationPermission.deniedForever) {
          normalDialog(context, 'หาพิกัดไม่ได้', 'กรุณา ไปเปิดการหาพิกัดก่อน');
          setState(() {
            deniedBool = true;
          });
        } else if (locationPermission == LocationPermission.denied) {
          locationPermission = await Geolocator.requestPermission();
          if (locationPermission == LocationPermission.deniedForever) {
            normalDialog(
                context, 'หาพิกัดไม่ได้', 'กรุณา ไปเปิดการหาพิกัดก่อน');
            setState(() {
              deniedBool = true;
            });
          }
        } else {
          Position position = await findPosition();
          setState(() {
            lat = position.latitude;
            lng = position.longitude;
            createMarker();
          });
        }
      } else {
        normalDialog(
            context, 'Location Service Off', 'Please Opent Location Service');
      }
    });
  }

  Future<Position> findPosition() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: load
          ? ShowProgress()
          : locationServiceEnble
              ? deniedBool
                  ? Text('Denies True')
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat, lng),
                        zoom: 16,
                      ),
                      onMapCreated: (controller) {},
                      markers: Set<Marker>.of(markers.values),
                    )
              : Center(
                  child: buildElevatedButton(),
                ),
    );
  }

  ElevatedButton buildElevatedButton() {
    return ElevatedButton(
        onPressed: () {
          Geolocator.openLocationSettings().then((value) => exit(0));
        },
        child: Text('Open Location Service'));
  }

  Map<MarkerId, Marker> markers = {};

  void createMarker() => addMarker(LatLng(lat, lng), 'id', 'คุณอยู๋ที่นี่', 'lat = $lat, lng = $lng');

  void addMarker(LatLng latLng, String id, String title, String snapet) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      position: latLng,
      infoWindow: InfoWindow(title: title, snippet: snapet)
    );
    markers[markerId] = marker;
  }
}
