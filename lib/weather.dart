import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'constraints.dart' as k;
class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  DateTime now = DateTime.now();
  String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
  String monthAndDate = DateFormat('MMMM d').format(DateTime.now());
  String formattedTime = DateFormat('HH:mm').format(DateTime.now());

  bool isLoaded=false;
  num? temp;
  num? pressure;
  num? humidity;
  num? cover;
  late int sunset;
  late int sunrise;

  var dt_sunrise;
  var dt_sunset;

  String cityname='';
  String description='';

  void initState() {
    // TODO : implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/beautiful-mountains.jpg',),
                fit: BoxFit.fill
            )
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 14, top: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cityname.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: Colors.white,
                        fontFamily: 'Prata'),),
                    Text('${dayOfWeek}, ${monthAndDate}', style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 28,
                        color: Colors.white,
                        fontFamily: 'Prata'),),
                  ],
                ),

                //SizedBox(height: 80,),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      Icon(Icons.cloud, size: 68, color: Colors.white,),
                      Text('${description.toUpperCase()}', style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.white),),
                    ],
                  ),
                ),
                //SizedBox(height: 60,),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_circle_outlined, size: 60,
                        color: Colors.white,),
                      // Text('${DateFormat('hh:mm a').format(dt_sunset)}', style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 26,
                      //     color: Colors.white),),
                      SizedBox(width: 50,),
                      Icon(Icons.cloud_circle_outlined, size: 60,
                        color: Colors.white,),
                      // Text('${DateFormat('hh:mm a').format(dt_sunrise)}', style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 26,
                      //     color: Colors.white),),
                    ],
                  ),
                ),
                //SizedBox(height: 90,),
                Center(
                  child: Text('${temp?.toInt()}°C', style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 120,
                      color: Colors.white.withOpacity(.6)),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true, //last known position
    );
    if (position != null) {
      print('lat: ${position.latitude},long: ${position.longitude}');
      getCurrentCityWeather(position);
    }
    else {
      print('Data Unavailable');
    }
  }

  getCurrentCityWeather(Position pos)async{
    var client=http.Client();
    var url='${k.domain}lat=${pos.latitude}&lon=${pos.longitude}&appid=${k.Apikey}';
    print(url);
    var uri=Uri.parse(url);
    var response=await client.get(uri);
    if(response.statusCode == 200){
      var data=response.body;
      var decodedData=jsonDecode(data);
      print(data);
      updateUI(decodedData);
      setState(() {
        isLoaded=true;
      });
    }
    else{
      print('Error : ${response.statusCode}');
    }
  }

  updateUI(var decodedData){
    setState(() {

      if(decodedData==null){
        temp=0;
        pressure=0;
        humidity=0;
        cover=0;
        cityname='Not Available';
      }
      else{
        temp=decodedData['main']['temp']-273;
        pressure=decodedData['main']['pressure'];
        humidity=decodedData['main']['humidity'];
        cover=decodedData['clouds']['all'];
        cityname=decodedData['name'];
        sunrise=decodedData['sys']['sunrise'];
        sunset=decodedData['sys']['sunset'];
        description=decodedData['weather'][0]['description'];

        dt_sunrise = DateTime.fromMillisecondsSinceEpoch(sunrise);
        dt_sunset = DateTime.fromMillisecondsSinceEpoch(sunset);

      }
    });
  }

  getCityWeather(String cityname) async{
    var client=http.Client();
    var url='${k.domain}q=$cityname&appid=${k.Apikey}';
    var uri=Uri.parse(url);
    var response=await client.get(uri);
    if(response.statusCode == 200){
      var data=response.body;
      var decodedData=jsonDecode(data);
      print(data);
      updateUI(decodedData);
      setState(() {
        isLoaded=true;
      });
    }
    else{
      print(response.statusCode);
    }
  }

  @override
  void dispose(){
    // TODO: implement dispose();
    super.dispose();
  }
}

