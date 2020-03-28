import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  static MqttClient client;

  static String name, portal, mykey;
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  final _key = GlobalKey<FormState>();
  bool _obscureText;
  Future login() async {
    if (_key.currentState.validate()) {
      name = _username.text;
      mykey = _password.text;
      portal = "io.adafruit.com";
      Map connectFile = {
        "broker": "io.adafruit.com",
        "username": name,
        "key": mykey
      };
      Future<MqttClient> _login() async {
        // TBD Test valid broker and key
        print('in _login....broker  : ${connectFile['broker']}');
        print('in _login....key     : ${connectFile['key']}');
        print('in _login....username: ${connectFile['username']}');

        client = MqttClient(connectFile['broker'], connectFile['key']);
        final MqttConnectMessage connMess = MqttConnectMessage()
            .authenticateAs(connectFile['username'], connectFile['key'])
            .withClientIdentifier('myClientID')
            .keepAliveFor(60) // Must agree with the keep alive set above or not set
            .withWillTopic(
                'willtopic') // If you set this you must set a will message
            .withWillMessage('My Will message')
            .startClean() // Non persistent session for testing
            .withWillQos(MqttQos.atMostOnce);
        print('Adafruit client connecting....');
        client.connectionMessage = connMess;

        /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
        /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
        /// never send malformed messages.
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
          Navigator.pushNamed(context, 'home_page');
        } else {
          /// Use status here rather than state if you also want the broker return code.
          
          
          print(
              'Adafruit client connection failed - disconnecting, status is ${client.connectionStatus}');
          client.disconnect();
          client = null;
        }
        return client;
      }

      MqttClient  _myClient = await _login();
      print(_myClient);
       if(_myClient== null){
      
            showDialog(context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Error"),
                    content:
                        Text("Could not Log In. Please check your connection"));
              });
        
      }
    }}

  

  @override
  void initState() {
    // TODO: implement initState
    _obscureText = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            title: Row(children: <Widget>[
          Container(
            child: Image.asset('images/light.png'),
            margin: EdgeInsets.only(top: 8, bottom: 8),
          ),
          Text("Smart Energy Saver")
        ])),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width / 2,
                alignment: Alignment.center,
                child: Image.asset('images/light.png'),
                margin: EdgeInsets.all(50)),
            Form(
                key: _key,
                child: SingleChildScrollView(
                    child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16, top: 32),
                      child: TextFormField(
                        validator: (val) =>
                            val.isEmpty ? "Username cannot be empty" : null,
                        controller: _username,
                        decoration: InputDecoration(
                            hintText: 'Username',
                            suffixIcon: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(width: 4.0))),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 16, right: 16, top: 32),
                        child: TextFormField(
                            validator: (val) =>
                                val.isEmpty ? "AIO Key cannot be empty" : null,
                            controller: _password,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                                hintText: 'AIO Key',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !(_obscureText);
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    borderSide: BorderSide(width: 2.0))))),
                    Container(
                        margin: EdgeInsets.only(top: 32),
                        child: RaisedButton(
                          splashColor: Colors.blue,
                          child: Text('Login',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          elevation: 5.0,
                          onPressed: login,
                          color: Colors.amberAccent,
                        ))
                  ],
                )))
          ]),
        ));
  }
}
