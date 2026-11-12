import 'dart:isolate';

// you the person in an isolated room
// tomain means after recieving the message it will first use the address before sending it to main
void actor(SendPort toMain) {
  // your mail box, recieves incomming messages
  final inbox = ReceivePort();

  toMain.send(inbox.sendPort); //address

  inbox.listen((msg) => print('Actor recieved msg : $msg'));
}

void main() async {
  final mainInbox = ReceivePort();
  await Isolate.spawn(actor, mainInbox.sendPort);
  final toActor = await mainInbox.first as SendPort;

  toActor.send('Hello from main');
}
