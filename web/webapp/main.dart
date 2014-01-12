import 'package:stream/stream.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../shared/events.dart';
import '../shared/verifications.dart';

List<ClientHandler> clients = [];

// TODO: this code is almost same as in client side. Factor out to library.
var r = new Random();
var futureId = 0;
var verificationFutures = new Map<num, Completer<VerificationResult>>();
void log(msg) {
  print(msg);
}
var myId = "[server]";

void broadcast(e) {
  print("Broadcasting message $e");
  clients.forEach((client) {
    if (client.isActive()) {
      client.sendMessage(e);
    }
  });
}

void sendOrResolveLocally(VerificationEvent v, completer) {
  if (r.nextDouble() < PROBABILITY_OF_DELEGATING) {
    // Send to the client.
    log("Sending to client");
    var activeClients = clients.where((x) => x.isActive());
    if (activeClients.length > 0) {
      var clients = [];
      clients.addAll(activeClients);
      clients.shuffle(new Random());
      var client = clients[0];
      client.sendMessage(JSON.encode(v));
    } else {
      log("There are no active clients. Message will be lost, alas!");
    }
    //socket.send(JSON.encode(verifyEvent));
  } else {
    log("Completing locally");
    var w = localVerify(v, myId);
    log("${w.toJson()}");
    completer.complete(w);
  }
}

Future<VerificationResult> verifySomewhere(VerificationEvent v) {
  var completer = new Completer();
  futureId++;
  var verificationId = futureId.toString() + myId;
  verificationFutures[verificationId] = completer;
  v.verificationId = verificationId;
  sendOrResolveLocally(v, completer);
  return completer.future;
}

class ClientHandler {
  String clientId;
  WebSocket socket;
  bool active = true;
  var r = new Random();

  ClientHandler(this.clientId, this.socket);

  void handleMessage(e) {
    var messageObj = JSON.decode(e);
    print("Got $e in client $clientId");

    switch (getEventType(messageObj)) {
      case KEYPRESS_EVENT:
        broadcast(e);
        break;
      case PING_EVENT:
        pong();
        break;
      case VERIFY_EVENT:
        VerificationEvent v = new VerificationEvent.fromParsedJson(messageObj);
        verifySomewhere(v).then((VerificationResult r) => broadcast(JSON.encode(r.toJson())));
        break;
      case VERIFICATION_DONE_EVENT:
        // Just broadcast this event so everybody knows.
        broadcast(e);
        break;
      default:
        print("Unknown event type ${getEventType(messageObj)}");
    }
  }

  void handleDone() {
    print("Client $clientId left.");
    active = false;
  }

  void sendMessage(e) {
    socket.add(e);
  }

  bool isActive() {
    return active;
  }

  void pong() {
    log("ponging $clientId!");
    var pongEvent = new PongEvent(clientId);
    socket.add(JSON.encode(pongEvent.toJson()));
  }
}

void handleWebSocket(WebSocket w) {
  ClientHandler clientHandler = new ClientHandler("Client #" + (clients.length + 1).toString(), w);
  clients.add(clientHandler);
  log("Client ${clientHandler.clientId} connected.");
  w.listen(clientHandler.handleMessage, onDone: clientHandler.handleDone);
}

void main() {
  new StreamServer(uriMapping: {
    "ws:/ws": handleWebSocket
  }).start();
}
