import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shell/Service/StoreToFirebase.dart';
import 'package:shell/Service/UserModel.dart';

abstract class BaseAuth {
  Future<User> signInWithEmailAndPassword(String _email, String _password);
  Future<User> signInWithGoogle();
  Future<User> signInWithFacebook();
  Future<String> currentUser();
  Stream<User> get onAuthStateChanged;
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FacebookLogin facebookLogin = new FacebookLogin();

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

  @override
  Future<User> signInWithEmailAndPassword(
      String _email, String _password) async {
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
            email: _email, password: _password))
        .user;
    storeFirebaseUser(user);
    return _userFromFirebase(user);
  }

  @override
  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    storeFirebaseUser(user);
    // print("******");
    // print(user);
    // print("******");
    return _userFromFirebase(user);
  }

  @override
  Future<User> signInWithFacebook() async {
    await facebookLogin.logIn(["email", "public_profile"]).then((result) async {
      if (result.status == FacebookLoginStatus.loggedIn) {
        AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);
        FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
        // print("******");
        // print(user);
        // print("******");
        storeFirebaseUser(user);
        return _userFromFirebase(user);
      } else {
        print("Not Logged In!");
        return null;
      }
    }).catchError((err) {
      print("Error: $err");
      return null;
    });
    return null;
  }

  @override
  Future<String> currentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user != null ? user.uid : null;
  }

  @override
  Future<void> signOut() async {
    return _auth.signOut();
  }

  @override
  Stream<User> get onAuthStateChanged {
    return _auth.onAuthStateChanged.map(_userFromFirebase);
  }
}
