
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:shell/Service/UserModel.dart';

void storeFirebaseUser(FirebaseUser user){
  final dbReference = FirebaseDatabase.instance.reference();
  var usersNode = dbReference.child("users");

  usersNode.child(user.uid).set({
    "email" : user.email,
    "name" : user.displayName,
    "profileImage" : user.photoUrl,
  });
}