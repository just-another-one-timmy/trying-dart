import 'dart:html';

void log(msg) {
  document.querySelector("#log").append(new LIElement()..text=msg);
}

void main() {
  document.querySelector("#hello").innerHtml = "<b>Hi from Dart!</b>";
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
}
