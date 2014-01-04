import 'package:stream/stream.dart';
import 'dart:io';
import 'dart:async';

void log(msg) {
  print(msg);
}

void handleMessage(e) {
  print("Got message $e");
}

void handleDone() {
  print("Some client left.");
}

var clients = 0;

class ClientHandler {
  int clientId;
  WebSocket socket;

  ClientHandler(this.clientId, this.socket);

  void handleMessage(e) {
    print("Got $e in client $clientId");
    socket.add("You're my client $clientId");
  }

  void handleDone() {
    print("Client $clientId left.");
  }
}

void handleWebSocket(WebSocket w) {
  ClientHandler clientHandler = new ClientHandler(clients++, w);
  log("Client ${clientHandler.clientId} connected.");
  w.listen(clientHandler.handleMessage, onDone: clientHandler.handleDone);
}

int clientsCount = 0;

void main() {
  new StreamServer(uriMapping: {
    "ws:/ws": handleWebSocket
  }).start();
}
