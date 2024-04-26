import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

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
    await Future.delayed(const Duration(seconds: 3));

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacementNamed("/Login");
    } else {
      bool existe = await checkExistingProfile();
      if (existe) {
        Navigator.of(context).pushReplacementNamed("/Main");
      } else {
        Navigator.of(context).pushReplacementNamed("/OnBoarding");
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
            color: const Color(0XFF0f7991),
          ),
          const Center(
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
          const Positioned(
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

