library events;

import 'dart:convert';

const KEYPRESS_EVENT = 'keypress';
const PING_EVENT = 'ping';
const PONG_EVENT = 'pong';
const VERIFY_EVENT = 'verify';
const VERIFICATION_DONE_EVENT = 'verified';

const CLIENT_ID = 'clientId';
const MESSAGE_TYPE = 'type';
const DATA_TO_VERIFY = 'dataToVerify';

// Can be true or false.
const VERIFICATION_VERDICT = 'verificationVerdict';
// Explains failed verification.
const VERIFICATION_EXPLANATION = 'verificationExplanation';

const VERIFICATION_ID = 'verificationId';

const VERIFIERS = 'verifiers';

final KEYPRESS_EVENT_JSON = JSON.encode({'type': KEYPRESS_EVENT});
final PING_EVENT_JSON = JSON.encode({'type': PING_EVENT});

const PROBABILITY_OF_DELEGATING = .8;

String getEventType(eventJsonObject) {
  return eventJsonObject[MESSAGE_TYPE];
}

class VerificationResult {
  bool verificationVerdict;
  String verificationExplanation;
  String clientId;
  List<String> verifiers;
  String verificationId;

  VerificationResult.fromParsedJson(json) {
    this.clientId = json[CLIENT_ID];
    this.verificationExplanation = json[VERIFICATION_EXPLANATION];
    this.verificationVerdict = json[VERIFICATION_VERDICT];
    this.verifiers = json[VERIFIERS];
    this.verificationId = json[VERIFICATION_ID];
  }
  VerificationResult(this.verificationVerdict, this.verificationExplanation, this.clientId, this.verifiers, this.verificationId);

  dynamic toJson() {
    var response = {
      MESSAGE_TYPE: VERIFICATION_DONE_EVENT,
      VERIFICATION_VERDICT: this.verificationVerdict,
      VERIFICATION_EXPLANATION: this.verificationExplanation,
      CLIENT_ID: this.clientId,
      VERIFIERS: this.verifiers,
      VERIFICATION_ID: this.verificationId,
    };
    return response;
  }
}

class VerificationEvent {
  String dataToVerify;
  String clientId;
  List<String> verifiers = [];
  VerificationEvent(this.dataToVerify, this.clientId);
  String verificationId;

  VerificationEvent.fromParsedJson(json) {
    this.dataToVerify = json[DATA_TO_VERIFY];
    this.clientId = json[CLIENT_ID];
    this.verifiers = [];
    verifiers.addAll(json[VERIFIERS]);
    this.verificationId = json[VERIFICATION_ID];
  }

  dynamic toJson() {
    var response = {
      MESSAGE_TYPE: VERIFY_EVENT,
      DATA_TO_VERIFY: dataToVerify,
      CLIENT_ID: this.clientId,
      VERIFIERS: verifiers,
      VERIFICATION_ID: verificationId
    };
    return response;
  }
}

class PingEvent {
  dynamic toJson() {
    var response = {
      MESSAGE_TYPE: PING_EVENT
    };
    return response;    
  }
}

class KeypressEvent {
  String clientId;
  KeypressEvent(this.clientId);
  dynamic toJson() {
    var response = {
      MESSAGE_TYPE: KEYPRESS_EVENT,
      CLIENT_ID: clientId
    };
    return response;    
  }

  KeypressEvent.fromParsedJson(json) {
    clientId = json[CLIENT_ID];
  }
}

class PongEvent {
  String clientId;
  PongEvent(this.clientId);
  dynamic toJson() {
    var response = {
      MESSAGE_TYPE: PONG_EVENT,
      CLIENT_ID: this.clientId,
    };
    return response;    
  }

  PongEvent.fromParsedJson(json) {
    clientId = json[CLIENT_ID];
  }
}