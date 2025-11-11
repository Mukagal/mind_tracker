/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn.instance;

  static Future<void> initialize() async {
    await _googleSignIn.initialize(
    );
  }

  static Future<User?> signInWithGoogle() async {
    try {
      if (_googleSignIn.supportsAuthenticate()) {
        final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        return userCredential.user;
      } else {
        print('authenticate() not supported on this platform');
        return null;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
*/
