library verifications;

import 'events.dart';

void verifyMinLength5(String message) {
  if (message.length < 5) {
    throw "Minimum length is 5.";
  }
}

void verifyMaxLength10(String message) {
  if (message.length > 10) {
    throw "Maximum length is 10.";
  }
}

void verifyThirdCharIsBang(String message) {
  if (message[2] != '!') {
    throw "message[2] must be '!'.";
  }
}

void verifySecondCharIsNotBang(String message) {
  if (message[1] == '!') {
    throw "message[1] must not be '!'.";
  }
}

void runAllVerifications(String message) {
  verifyMinLength5(message);
  verifyMaxLength10(message);
  verifyThirdCharIsBang(message);
  verifySecondCharIsNotBang(message);
}

VerificationResult localVerify(VerificationEvent v, verificatorId) {
  var verificationVerdict = true;
  var verificationExplanation = "yokatta";
  var verifiers = [];
  verifiers.addAll(v.verifiers);
  verifiers.add(verificatorId);
  try {
    runAllVerifications(v.dataToVerify);
  } catch (e) {
    verificationVerdict = false;
    verificationExplanation = e;
  }
  return new VerificationResult(verificationVerdict, verificationExplanation, v.clientId, verifiers, v.verificationId);  
}