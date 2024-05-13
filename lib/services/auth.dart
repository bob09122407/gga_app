
import 'package:fh_mini_app/screens/authenticate/authenticate.dart';
import 'package:fh_mini_app/screens/pod_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //auth change user stream (detects any changes in the authentication of user, constantly)
  // and returns a User obj back, use this to determine which screen to show
  Stream<User?> get userStream {
    return _auth.authStateChanges();
  }


  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;

  // String? inputData() {
  //   final User? user = auth.currentUser;
  //   final String? email = user!.email;
  //   debugPrint(email);
  //   return email;
  // }

  // sign in anonymously
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // sign in with emial and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? emailUser = result.user;
      return emailUser;
    } catch (e) {
      debugPrint(e.toString());
      return null; // Return null in case of an error
    }
  }

  Future<User?> registeredWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Store user data in Firestore
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': user.email,
          // Add more user data fields as needed
        });
      }

      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null; // Return null in case of an error
    }
  }


  // register with email and password
  // Future registeredWithEmailAndPassword(String email, password) async {
  //   try {
  //     UserCredential result = await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     User? emailUser = result.user;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return null;
  //   }

    // Future<User?> registeredWithEmailAndPassword(String email, password) async {
    //   try {
    //     UserCredential result = await _auth.createUserWithEmailAndPassword(
    //       email: email,
    //       password: password,
    //     );
    //     User? emailUser = result.user;
    //     return emailUser;
    //   } catch (e) {
    //     debugPrint(e.toString());
    //     return null;
    //   }
    // }


// ...

  Future googleLogin(BuildContext context) async {
    print("Attempting Google Sign-In...");
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      print("Google Sign-In canceled or failed.");
      return;
    }

    print("Google Sign-In successful.");

    _user = googleUser;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("Firebase Sign-In successful.");

      // Check if the user is logged in after Firebase Sign-In
      if (isUserLoggedIn) {
        print("User is logged in.");

        // Navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Authenticate()), // Replace `HomePage` with your actual home page widget
        );
      }
    } catch (e) {
      print("Firebase Sign-In failed: $e");
    }
  }

// ...

  bool get isUserLoggedIn {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }



  // sign out
  Future signOut() async {
    try {
      debugPrint("trying _auth signout");
      return await _auth.signOut();
    } catch (e) {
      debugPrint("Error with _auth signout");
      debugPrint(e.toString());
      return null;
    } finally {
      debugPrint("_auth signout successful");
    }
  }
}
