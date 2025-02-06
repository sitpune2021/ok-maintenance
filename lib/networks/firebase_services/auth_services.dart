import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../main.dart';
import '../../models/user_data.dart';
import '../../networks/rest_apis.dart';

class AuthService {
  Future<UserCredential> getFirebaseUser() async {
    UserCredential? userCredential;
    try {
      /// login with Firebase
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: appStore.userEmail, password: DEFAULT_PASSWORD_FOR_FIREBASE);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        /// register user in Firebase
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: appStore.userEmail, password: DEFAULT_PASSWORD_FOR_FIREBASE);
      }
    }
    if (userCredential != null && userCredential.user == null) {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: appStore.userEmail, password: DEFAULT_PASSWORD_FOR_FIREBASE);
    }

    if (userCredential != null) {
      return userCredential;
    } else {
      throw errorSomethingWentWrong;
    }
  }

  Future<void> verifyFirebaseUser() async {
    try {
      UserCredential userCredential = await getFirebaseUser();

      UserData userData = UserData();
      userData.id = appStore.userId;
      userData.email = appStore.userEmail;
      userData.firstName = appStore.userFirstName;
      userData.lastName = appStore.userLastName;
      userData.profileImage = appStore.userProfileImage;
      userData.updatedAt = Timestamp.now().toDate().toString();

      /// Check email exists in Firebase
      /// If not exists, register user in Firebase,
      /// If exists, login with Firebase
      /// Redirect to Dashboard

      /// add user data in Firestore
      userData.uid = userCredential.user!.uid;

      bool isUserExistWithUid = await userService.isUserExistWithUid(userCredential.user!.uid);

      if (!isUserExistWithUid) {
        userData.createdAt = Timestamp.now().toDate().toString();
        await userService.addDocumentWithCustomId(userCredential.user!.uid, userData.toFirebaseJson());
      } else {
        /// Update user details in Firebase
        await userService.updateDocument(userData.toFirebaseJson(), userCredential.user!.uid);
      }

      /// Update UID in Laravel DB
      updateProfile({'uid': userCredential.user!.uid});

      await appStore.setUId(userCredential.user!.uid);
    } catch (e) {
      log('verifyFirebaseUser $e');
    }
  }

  //region Google Login
  Future<User> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);

      final User currentUser = FirebaseAuth.instance.currentUser!;
      assert(user.uid == currentUser.uid);

      try {
        AuthCredential emailAuthCredential = EmailAuthProvider.credential(
            email: user.email!, password: DEFAULT_FIREBASE_PASSWORD);
        user.linkWithCredential(emailAuthCredential);
      } catch (e) {
        log(e);
      }

      await googleSignIn.signOut();

      return user;
    } else {
      appStore.setLoading(false);
      throw USER_NOT_CREATED;
    }
  }

}
