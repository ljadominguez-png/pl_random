// do not communicate by sharing memory, share memory by communicating it
import 'dart:async';

void main(List<String> args) async {
  // StreamController??
  /**
   * A StreamController acts like a two-ended pipe for data:

The Input (sink): Where you drop data in (channel.add(...)).

The Output (stream): Where data comes out for listeners (channel.stream).

<int> specifies that this pipe only accepts integers.
   */
  final channel = StreamController<int>();
  //what does this do?
  /**
   * 
   * This sets up a listener at the exit end of the pipe:

Whenever an item reaches the end of the stream, Dart triggers this callback function (value) => ....

It does not block or stop the program; it registers a subscription and tells Dart's event loop: 
"Whenever a new integer comes out of channel.stream, run this print statement."
   */
  channel.stream.listen((value) => print('Recieved from channel: $value'));

  channel.add(10);

  channel.add(20);

  await Future.delayed(const Duration(milliseconds: 20));
  await channel.close();
}
