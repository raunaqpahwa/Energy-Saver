import 'package:flutter/material.dart';
import './LoginPage.dart';
import 'package:splashscreen/splashscreen.dart';
import './HomePage.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,routes: {
      'home_page':(context)=>HomePage()
    },
      title: 'Smart Energy Saver',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(bottom: 8,top: 8),
                  child: Image.asset('images/light.png')),
              Text("Smart Energy Saver")
            ],
          ),
        ),
        body: SplashScreen(
            seconds: 2,
            navigateAfterSeconds: LoginPage(),
            title: Text(
              "Smart Energy Saver",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36.0),
            ),
            image: Image.asset('images/light.png'),
            backgroundColor: Colors.white,loadingText: Text("Save Money, Save Energy",style: TextStyle(fontSize: 30.0)),
            styleTextUnderTheLoader: TextStyle(fontWeight: FontWeight.bold,fontSize: 28.0),
            photoSize: 100.0,
            loaderColor: Colors.blue));
  }
}
