import 'package:stream/stream.dart';
import 'dart:io';
import 'dart:async';

void log(msg) {
  print(msg);
}

// TODO: figure out how to handle situation when client closes websocket.
// Currently server keeps sending messages somewhere o_O without any
// exceptions.
void handleWebSocket(WebSocket w) {
  log("Client connected.");
  clientsCount++;
  var currentClient = clientsCount;
  var currentMessage = 0;
  w.listen((e) {
    log("Client says ${e}");
    // Logically this work's only when each client only says "Ping" once.
    new Timer.periodic(
        new Duration(seconds: 1),
        (t) {
          currentMessage++;
          log("Sending a message to client.");
          w.add("Pong, you're my client #${currentClient} and this is my message #${currentMessage} to you.");
          if (currentMessage >= 10) {
            w.add("You've received too much attention from me. Bye-bye.");
            w.close().then((_) {
              log("Closed websocket for client #${currentClient}.");
            });
            t.cancel();
          }
        });
  });
}

int clientsCount = 0;

void main() {
  new StreamServer(uriMapping: {
    "ws:/ws": handleWebSocket
  }).start();
}
