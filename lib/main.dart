import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinkit;
import 'package:add_2_calendar/add_2_calendar.dart' as calender;
import 'package:url_launcher/url_launcher.dart' as launcher;

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MainPage",
      home: MainApp() ,
    );
  }
}
class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

String convertStrToInt(String s) {
  if(s == "Jan") return "01";
  else if(s=="Feb") return "02";
  else if(s=="Mar") return "03";
  else if(s=="Apr") return "04";
  else if(s=="May") return "05";
  else if(s=="Jun") return "06";
  else if(s=="Jul") return "07";
  else if(s=="Aug") return "08";
  else if(s=="Sep") return "09";
  else if(s=="Oct") return "10";
  else if(s=="Nov") return "11";
  else if(s=="Dec") return "12";
}

class _MainAppState extends State<MainApp> {
  var eventsFromServer = <dynamic>[];

  final globalKey = GlobalKey<ScaffoldState>();
  Widget textFieldGenerator(Map event) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
            children: <Widget>[
            Text("Code: "),
            Text(
                "${event["code"]}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
        ),
        Row(
          children: <Widget>[
            Text("Name: "),
            Flexible(
              child: Text(
                "${event["name"]}",
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text("Start Date: "),
            Text(
              "${(event["startDate"] as String).trim()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text("Start Time: "),
            Text(
              "${(event["startTime"] as String).trim()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text("End Date: "),
            Text(
              "${(event["endDate"] as String).trim()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text("End Time: "),
            Text(
              "${(event["endTime"] as String).trim()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget card(Map event) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: (Container(
        height: 150,
        decoration: BoxDecoration(
            color: Color.fromRGBO(217, 217, 217, 1),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: textFieldGenerator(event),
                ),
              ),
            ),
            Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                          child: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                            ),
                            color: Colors.white70,
                            onPressed: () {
                              //calender.Event e = calender.Event();
                              var startDate = (event["startDate"] as String).trim().split(" ");
                              startDate[1] = convertStrToInt(startDate[1]);
                              var endDate = (event["endDate"] as String).trim().split(" ");
                              endDate[1] = convertStrToInt(endDate[1]);
                              var startTime = (event["startTime"] as String).trim();
                              var endTime= (event["endTime"] as String).trim();
                              var start = '${startDate[2]}-${startDate[1]}-${startDate[0]} ${startTime}+05:30';
                              var end = '${endDate[2]}-${endDate[1]}-${endDate[0]} ${endTime}+05:30';
                              calender.Event e = calender.Event(
                                title: event["code"] + " - "+ event["name"],
                                description: event["href"],
                                startDate: DateTime.parse(start),
                                endDate: DateTime.parse(end),
                              );
                              calender.Add2Calendar.addEvent2Cal(e);
                              globalKey.currentState.showSnackBar(SnackBar(content: Text(DateTime.parse(start).toString())));

                            },
                          ),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child :Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            child: IconButton(
                              icon: Icon(
                                Icons.open_in_browser,
                              ),
                              onPressed: () async {
                                var url = event["href"] as String;
                                print(url);
                                if (await launcher.canLaunch(url)) {
                                  await launcher.launch(url);
                                } else {
                                  globalKey.currentState.showSnackBar(SnackBar(content: Text("Could not launch WebBrowser")));
                                }
                              },
                              color: Colors.white70,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Color.fromRGBO(83, 132, 181, 1),
                            ),
                          ),
                        )
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
  List<Widget> cardStack() {
    var cards = <Widget>[];
    for (var i in eventsFromServer) {
      cards.add(card(i));
    }
    var v = Center(
      child: spinkit.SpinKitCircle(
        color: Colors.lightBlue[900],
        size: 100,
      ),
    );
    if(eventsFromServer.length == 0) return <Widget>[v];
    else return cards;
  }
  void updateState() async {
    var resp = await http.get("https://cp-events-api.herokuapp.com/api/v1/codechef");
    this.setState((){
      eventsFromServer = jsonDecode(resp.body)["events"] as List<dynamic>;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    double width_screen = MediaQuery.of(context).size.width;
    var color = Color.fromRGBO(52,73,94,1);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
      )
    );
    return Scaffold(
      key: globalKey,
        body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(52,73,94,1),
                    border: Border.all(width: 0, color: Color.fromRGBO(52,73,94,1)),
                  ),
                  child: Center(
                    child: Image(
                        image: AssetImage("assets/images/logo.png"),
                      ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(52,73,94,1),
                      border: Border.all(width: 0, color: Color.fromRGBO(52,73,94,1)),
                    ),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          )
                        ),
                        width: width_screen-width_screen*0.08,
                        child: Padding(
                          child: ListView(
                            padding: EdgeInsets.all(10),
                            children: cardStack(),
                          ),
                          padding: EdgeInsets.all(10),
                        ),
                      ) ,
                    ),
                  ),
                )
              ],
          ),
        ),
    );
  }
}
