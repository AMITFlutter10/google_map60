import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

CameraPosition  initialCameraPosition = const CameraPosition(
  target: LatLng(26.8206, 30.8025),
  tilt: 45,
  bearing: 45,
  zoom: 7

);
late LatLng currentPosition;
onCameraMove(CameraPosition position)=> currentPosition = position.target;

late GoogleMapController googleMapController;
// create function for get  user current location
Future<Position>getUserCurrentLocation()async{
  await Geolocator.requestPermission().then((value){}).
  onError((error, stackTrace) async{
    await Geolocator.requestPermission();
    print(error.toString());
  });
  return Geolocator.getCurrentPosition();
}

Set<Marker>myMarkers ={
  Marker(markerId: MarkerId("L1"),
      position: LatLng(initialCameraPosition.target.latitude,
          initialCameraPosition.target.longitude) ,
  ),

};
Completer<GoogleMapController> _controller = Completer();

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        // old
        // onMapCreated: (controller){
        //   googleMapController  = controller;
        // },
        // current
        onMapCreated: (controller){
          _controller.complete(controller);
        },
         onCameraMove: onCameraMove ,
         markers: myMarkers,
         onTap: (LatLng current ){
          setState(() {
          myMarkers.add(Marker(markerId: const MarkerId("L2"),
          position: LatLng(current.latitude, current.longitude)
          ));
          });
         },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          getUserCurrentLocation().then((value) async {
            print(value.latitude.toString() + " " + value.longitude.toString());
              setState(() {
                myMarkers.add(Marker(markerId: MarkerId("L3"),
                  position: LatLng(value.latitude ,value.longitude),
                  // infoWindow: InfoWindow(title: "my current location")
                ));
              });
            CameraPosition cameraPosition = CameraPosition(target:
            LatLng(value.latitude, value.longitude),zoom: 20);

            final GoogleMapController controller = await _controller.future;
            setState(() {
              controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            });
          });
        },
        child: Icon(Icons.local_activity),
      ),

    );
  }
}
