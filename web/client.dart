import 'dart:html';
import 'dart:async';

void log(msg) {
  document.querySelector("#log").append(new LIElement()..text=msg);
}

WebSocket makeSocketConnection() {
  WebSocket ws = new WebSocket("ws://127.0.0.1:8080/ws");
  ws.onOpen.listen((e) {
    log("WebSocket opened.");
    ws.send("Ping!");
  });
  ws.onClose.listen((e) {
    log("WebSocket closed.");
  });
  ws.onMessage.listen((e) {
    log("Server says: ${e.data}");
  });
  return ws;
}

void buttonSubmitClick(e) {
  log("Clicked a button.");
}

void buttonConnectClick(e) {
  makeSocketConnection();
}

var buttonSubmit = document.querySelector("#submit");
var buttonConnect = document.querySelector("#connect");
var inputName = document.querySelector("#name");

void main() {
  buttonSubmit.onClick.listen(buttonSubmitClick);
  //buttonConnect.onClick.listen(buttonConnectClick);
  WebSocket ws1 = makeSocketConnection();
  WebSocket ws2 = makeSocketConnection();
  new Timer.periodic(new Duration(seconds: 2), (t) => ws2.send("Hi from ws1!"));
  new Timer.periodic(new Duration(seconds: 5), (t) => ws2.send("Hi from ws2!"));
}
