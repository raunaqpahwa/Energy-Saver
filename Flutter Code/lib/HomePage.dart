import 'package:flutter/material.dart';
import './LoginPage.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'Adafruit_feed.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State {
  static MqttClient client;
  TextEditingController _mine = TextEditingController();
  TextEditingController _threshold = TextEditingController();
  static String name = LoginPageState.name;
  static String mykey = LoginPageState.mykey;
  static String portal = "io.adafruit.com";
  String applianceText = "Not available";
  String myText;
  String myStateText;
  String applianceIsEnabled;
  bool isSubscribed;
  Map connectFile = {
    "broker": "io.adafruit.com",
    "username": name,
    "key": mykey
  };
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<MqttClient> _login() async {
    // TBD Test valid broker and key
    print('in _login....broker  : ${connectFile['broker']}');
    print('in _login....key     : ${connectFile['key']}');
    print('in _login....username: ${connectFile['username']}');

    client = MqttClient(connectFile['broker'], connectFile['key']);
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(connectFile['username'], connectFile['key'])
        .withClientIdentifier('Lenovo')
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    print('Adafruit client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXCEPTION::client exception - $e');
      client.disconnect();
      client = null;
      return client;
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('Adafruit client connected');
      client.subscribe("Harman_singh/feeds/onoff", MqttQos.atLeastOnce);
      client.subscribe("Harman_singh/feeds/threshold", MqttQos.atLeastOnce);
    } else {
      print(
          'Adafruit client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      client = null;
    }
    return client;
  }

  Future<bool> _connectToClient() async {
    if (client != null &&
        client.connectionStatus.state == MqttConnectionState.connected) {
      print('already logged in');
    } else {
      client = await _login();
      if (client == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> publish(String topic, String value) async {
    if (await _connectToClient() == true) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(value);
      var b =
          client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
    }
  }

  Future<String> subscribe(String topic) async {
    String myval;
    if (await _connectToClient() == true) {
      myval = await _subscribe(topic);
    }
    return myval;
  }

  Future _subscribe(String topic) async {
    print('Subscribing to the topic $topic');
    client.subscribe(topic, MqttQos.atLeastOnce);
    var c = client.updates.last;
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      AdafruitFeed.add(pt);
      print(
          'Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      if (pt == "on" || pt == "off")
        setState(() {
          myStateText = "Appliance is ${pt.toString()}";
          _mine.text = "Appliance is ${pt.toString()}";
        });
      else
        setState(() {
          _threshold.text = pt.toString();
          myText = pt.toString();
        });
      return pt.toString();
    });
  }

  @override
  initState() {
    isSubscribed = false;
    applianceIsEnabled = "off";
    _mine.text = "Hey";
    myText = "";
    myStateText = "Hey";
    _threshold.text = "";
    changeState();
    super.initState();
  }

  void changeState() async {
    String yoyo = await subscribe("Harman_singh/feeds/onoff");
    print(yoyo);
    applianceIsEnabled = yoyo;
    if (applianceIsEnabled == "on") {
      setState(() {
        myStateText = "Appliance is On";
        _mine.text = "Appliance is On";
      });
    } else if (applianceIsEnabled == "off") {
      setState(() {
        myStateText = "Appliance is Off";
        _mine.text = "Appliance is Off";
      });
    } else {
      setState(() {
        myText = applianceIsEnabled;
        _threshold.text = applianceIsEnabled;
        myStateText = "Values will appear here when they change";
        _mine.text = "Values will appear here when they change";
      });
    }
  }

  void publishThreshold(String val) {
    setState(() {
      _threshold.text = val;
    });
  }

  _launchURL() async {
    const url = 'https://io.adafruit.com/Harman_singh/feeds/power';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.blue.shade100,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  child: Image.asset('images/light.png')),
              Text("Smart Energy Saver")
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // RaisedButton(child:Text('Fetch'),onPressed: (){
                    //   //changeState();
                    // }),
                    Container(
                        margin: EdgeInsets.only(bottom: 16.0, top: 80),
                        child: Text(myStateText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold))),
                    Container(
                        margin: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(right: 16),
                                child: RaisedButton(
                                    color: Colors.amberAccent,
                                    child: Text("ON"),
                                    onPressed: () async {
                                      //client.setProtocolV311();

                                      publish("Harman_singh/feeds/onoff", "on");
                                    })),
                            RaisedButton(
                                color: Colors.amberAccent,
                                child: Text("OFF"),
                                onPressed: () async {
                                  //client.setProtocolV311();

                                  publish("Harman_singh/feeds/onoff", "off");
                                })
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.all(16.0),
                        child: Text("Enter your threshold ",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold))),
                    Container(
                        margin: EdgeInsets.only(left: 30, right: 30),
                        child: TextFormField(
                          controller: _threshold,
                          keyboardType: TextInputType.number,
                          onSaved: (String val) {
                            setState(() {
                              _threshold.text = val;
                            });
                          },
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        )),

                    Container(
                        margin: EdgeInsets.only(top: 56),
                        child: RaisedButton(
                            child: Text("Set Threshold"),
                            color: Colors.amberAccent,
                            onPressed: () {
                              if (_threshold.text == "" ||
                                  _threshold.text == "0") {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content:
                                            Text("Threshold cannot be empty"),
                                        title: Text("Error"),
                                      );
                                    });
                                return;
                              }
                              publish("Harman_singh/feeds/threshold",
                                  _threshold.text);
                              setState(() {
                                myText = _threshold.text;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text("Threshold has been sent"),
                                      title: Text("Success"),
                                    );
                                  });
                            })),
                    Container(
                        margin: EdgeInsets.only(top: 56),
                        child: Text("Your current threshold is ",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold))),
                    Container(
                        margin: EdgeInsets.all(16),
                        child: Text(myText == null ? "" : myText,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold))),
                    Container(
                        child: RaisedButton(
                            child: Text('Analyse Power Consumed'),
                            color: Colors.amberAccent,
                            onPressed: () {
                              _launchURL();
                            }))
                  ])),
        ));
  }
}
