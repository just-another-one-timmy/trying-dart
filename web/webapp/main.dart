import 'package:stream/stream.dart';
import 'dart:io';
import 'dart:async';

void log(msg) {
  print(msg);
}

void handleWebSocket(WebSocket w) {
  log("Client connected.");
  clientsCount++;
  var currentClient = clientsCount;
  var currentMessage = 0;
  w.listen((e) {
    log("Client says ${e}");
    new Timer.periodic(
        new Duration(seconds: 1),
        (t) {
          currentMessage++;
          w.add("Pong, you're my client #${currentClient} and this is my message #${currentMessage} to you.");
        });
  });
}

int clientsCount = 0;

void main() {
  new StreamServer(uriMapping: {
    "ws:/ws": handleWebSocket
  }).start();
}
