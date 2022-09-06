import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;

  var lat;
  var lon;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=f3b902a8b1bd6868c6286e55d217334b&units=metric";

    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=f3b902a8b1bd6868c6286e55d217334b&units=metric";

    var weatherResponce = await http.get(Uri.parse(weatherApi));
    var forecastResponce = await http.get(Uri.parse(forecastApi));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: weatherMap == null
            ? Center(child: CircularProgressIndicator())
            : Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(

                    //color: Color(0xffe9f3fb)
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xff33ccff), Color(0xffff99cc)])),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Colors.black,
                              ),
                              Text(
                                "${weatherMap!["name"]}",
                                style: TextStyle(
                                    color: Color(0xff14405c),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${Jiffy(DateTime.now()).format("EEE, h:mm")}",
                                style: TextStyle(
                                    color: Color(0xff14405c).withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Image.asset(
                        'images/sun1.png',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "${weatherMap!["weather"][0]["description"]}",
                        style: TextStyle(
                            color: Color(0xff14405c),
                            fontWeight: FontWeight.bold,
                            fontSize: 35),
                      ),
                      Text(
                        "${weatherMap!["main"]["temp"]}°",
                        style: TextStyle(
                            color: Color(0xff14405c).withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/feels.png',
                            height: 25,
                            width: 25,
                          ),
                          Text(
                            "Feels like ${weatherMap!["main"]["feels_like"]}°",
                            style: TextStyle(
                                color: Color(0xff14405c),
                                fontWeight: FontWeight.normal,
                                fontSize: 25),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'images/humidity.png',
                                height: 25,
                                width: 25,
                              ),
                              Text(
                                "Humidity: ${weatherMap!["main"]["humidity"]}",
                                style: TextStyle(
                                    color: Color(0xff14405c),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'images/presure.png',
                                height: 25,
                                width: 25,
                              ),
                              Text(
                                "Pressure :${weatherMap!["main"]["pressure"]}",
                                style: TextStyle(
                                    color: Color(0xff14405c),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'images/sunrise.png',
                                height: 25,
                                width: 25,
                              ),
                              Text(
                                "Sunrise :${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm a")}",
                                style: TextStyle(
                                    color: Color(0xff14405c),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'images/sunset.png',
                                height: 25,
                                width: 25,
                              ),
                              Text(
                                "Sunset :${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm a")}",
                                style: TextStyle(
                                    color: Color(0xff14405c),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Container(
                        height: 150,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: forecastMap!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  height: 150,
                                  width: 170,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 85, 119, 131)
                                          .withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                            "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE, h:mm")}"),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Image.asset(
                                          forecastMap!["list"][index]["weather"]
                                                      [0]["description"] ==
                                                  'broken clouds'
                                              ? 'images/cloud.png'
                                              : forecastMap!["list"][index]
                                                              ["weather"][0]
                                                          ["description"] ==
                                                      'overcust clouds'
                                                  ? 'images/cloud1.png'
                                                  : forecastMap!["list"][index]
                                                                  ["weather"][0]
                                                              ["description"] ==
                                                          'light rain'
                                                      ? 'images/rain.png'
                                                      : 'images/sun_cloud.png',
                                          height: 50,
                                          width: 50,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                            "${forecastMap!["list"][index]["weather"][0]["description"]}")
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                )));
  }
}
