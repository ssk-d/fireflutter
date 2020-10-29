import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

import 'dart:math';
import 'dart:convert';

String _createNonce(int length) {
  final random = Random();
  final charCodes = List<int>.generate(length, (_) {
    int codeUnit;

    switch (random.nextInt(3)) {
      case 0:
        codeUnit = random.nextInt(10) + 48;
        break;
      case 1:
        codeUnit = random.nextInt(26) + 65;
        break;
      case 2:
        codeUnit = random.nextInt(26) + 97;
        break;
    }

    return codeUnit;
  });

  return String.fromCharCodes(charCodes);
}

Future<OAuthCredential> createAppleOAuthCred() async {
  final nonce = _createNonce(32);
  print('nonce: $nonce');

  final nativeAppleCred = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: sha256.convert(utf8.encode(nonce)).toString(),
  );
  return new OAuthCredential(
    providerId: "apple.com", // MUST be "apple.com"
    signInMethod: "oauth", // MUST be "oauth"
    accessToken: nativeAppleCred
        .identityToken, // propagate Apple ID token to BOTH accessToken and idToken parameters
    idToken: nativeAppleCred.identityToken,
    rawNonce: nonce,
  );
}
