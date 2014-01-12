import 'dart:html';
import 'dart:async';
import 'dart:svg';
import 'dart:math';
import 'dart:convert';

import './shared/verifications.dart';
import './shared/events.dart';

var r = new Random();
var futureId = 0;
Map<num, Completer<VerificationResult>> verificationFutures = new Map<num, Completer<VerificationResult>>();

void log(msg) {
  document.querySelector("#log").append(new LIElement()..text=msg);
}

final DURATION_5_SECONDS = new Duration(seconds: 5);
const MAX_CIRCLES = 50;
const CIRCLE_RADIUS = 5;
num circles = 0;
String myId = "undefined";

WebSocket socket = null;

var buttonSubmit = document.querySelector("#submit");
var inputName = document.querySelector("#name");
var circlesSvg = document.querySelector("#circles");
var clientIdSpan = document.querySelector("#clientId");
var verificationResults = document.querySelector("#verificationResults");

void sendOrResolveLocally(VerificationEvent v, completer) {
  if (r.nextDouble() < PROBABILITY_OF_DELEGATING) {
    // Send to the server.
    v.verifiers.add(myId);
    log("Sending to server");
    log("Sent ${v.toJson()}");
    socket.send(JSON.encode(v.toJson()));
  } else {
    log("Completing locally");
    completer.complete(localVerify(v, myId));
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

void processVerificationResult(VerificationResult v) {
  if (v.clientId == myId) {
    verificationResults.innerHtml = '"${v.verificationExplanation}" - verified via ${v.verifiers}';
    if (!v.verificationVerdict) {
      verificationResults.classes.remove('success');
      verificationResults.classes.add('fail');
      addCircle('red');
    } else {
      verificationResults.classes.add('success');
      verificationResults.classes.remove('fail');
      addCircle('green');
    }
  } else {
    addCircle(v.verificationVerdict ? '#bbffbb' : '#ffbbbb');
  }
}

void buttonSubmitClick(e) {
  verifySomewhereThenInformServer(new VerificationEvent(inputName.value, myId));
}

void verifySomewhereThenInformServer(VerificationEvent v) {
  verifySomewhere(v).then((v) => socket.send(JSON.encode(v.toJson())));
}

void inputNameKeyDown(e) {
  KeypressEvent x = new KeypressEvent(myId);
  socket.send(JSON.encode(x.toJson()));
}

void addCircle(color) {
  log("Adding ${color} circle ");
  circles++;
  if (circles > MAX_CIRCLES) {
    circles = 0;
    circlesSvg.children.clear();
  }
  var circle = new SvgElement.svg("<circle fill='$color' cx='${circles * CIRCLE_RADIUS * 2 + CIRCLE_RADIUS}' cy='50' r='$CIRCLE_RADIUS'/>");
  circlesSvg.append(circle);
}

void onKeypress(KeypressEvent x) {
  addCircle(x.clientId == myId ? "#ddd" : "#222");
}

void onPong(PongEvent v) {
  log("Server says we're client ${v.clientId}");
  myId = v.clientId;
  clientIdSpan.setInnerHtml(myId);
  addCircle('navy');
}

void processMessage(msg) {
  log("Processing message $msg");
  var messageObj = JSON.decode(msg);
  var messageType = getEventType(messageObj);

  switch (messageType) {
    case KEYPRESS_EVENT:
      onKeypress(new KeypressEvent.fromParsedJson(messageObj));
      break;
    case PONG_EVENT:
      onPong(new PongEvent.fromParsedJson(messageObj));
      break;
    case VERIFICATION_DONE_EVENT:
      var verificationResult = new VerificationResult.fromParsedJson(messageObj);
      if (verificationFutures.containsKey(verificationResult.verificationId) &&
          !verificationFutures[verificationResult.verificationId].isCompleted) {
        verificationFutures[verificationResult.verificationId].complete(verificationResult);
      } else {
        processVerificationResult(verificationResult);
      }
      break;
    case VERIFY_EVENT:
      var verifyEvent = new VerificationEvent.fromParsedJson(messageObj);
      verifySomewhereThenInformServer(verifyEvent);
      break;
    default:
      log("Unknown message type: $messageType");
  }
}

WebSocket makeSocketConnection() {
  WebSocket ws = new WebSocket("ws://yuandakko.tok.corp.google.com:8080/ws");
  ws.onOpen.listen((e) {
    log("WebSocket opened.");
    ws.send(PING_EVENT_JSON);
  });
  ws.onClose.listen((e) {
    log("WebSocket closed.");
  });
  ws.onMessage.listen((e) {
    processMessage(e.data);
  });
  ws.onError.listen((e) {
    log("Web socket connection was lost. Retrying in 5 seconds.");
    var timer = new Timer(DURATION_5_SECONDS, () {
      makeSocketConnection();
    });
  });
  socket = ws;
}

void main() {
  makeSocketConnection();
  buttonSubmit.onClick.listen(buttonSubmitClick);
  inputName.onKeyDown.listen(inputNameKeyDown);
}
