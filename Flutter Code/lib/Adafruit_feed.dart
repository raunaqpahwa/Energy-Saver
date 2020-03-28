import 'dart:async';

class AdafruitFeed {
  static var _feedController = StreamController<String>();
  static Stream<String> get sensorStream => _feedController.stream;
  static void add(String value) {
    try {
      _feedController.add(value);
      print('---> added value to the Stream... the value is: $value');
    } catch (e) {
      print(
          '$value was published to the feed.  Error adding to the Stream: $e');
    }
  }
}