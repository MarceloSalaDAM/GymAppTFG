import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashView extends StatefulWidget {
  SplashView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashViewState();
  }
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    descargaDatos();
  }

  void descargaDatos() async {
    await Future.delayed(Duration(seconds: 4));

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).popAndPushNamed("/Login");
    } else {
      bool existe = await checkExistingProfile();
      if (existe) {
        Navigator.of(context).popAndPushNamed("/Main");
      } else {
        Navigator.of(context).popAndPushNamed("/OnBoarding");
      }
    }
  }

  Future<bool> checkExistingProfile() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    final docRef = db.collection("usuarios").doc(idUser);

    DocumentSnapshot docsnap = await docRef.get();

    return docsnap.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitChasingDots(
                  color: Colors.white,
                  size: 60.0,
                  duration: Duration(milliseconds: 2000),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image(
                image: AssetImage("assets/flutter.png"),
                height: 100,
                width: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
