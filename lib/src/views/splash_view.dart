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

/* Pantalla de splash con widget mas creativo
late AnimationController _controller;
bool isPlaying = false;
int maxDuration = 10;

@override
void initState() {
  super.initState();
  _controller = AnimationController(vsync: this, duration: Duration(seconds: maxDuration))
    ..addListener(() {
      setState(() {});
    })
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isPlaying = false;
      }
    });
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  double val = (_controller.value * maxDuration);
  return Scaffold(
    backgroundColor: const Color(0xFF232424),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              (val.toInt() * 10).toString(),
              style: const TextStyle(color: Colors.white, fontSize: 50),
            ),
            Text(
              ".${val.toStringAsFixed(1).substring(val.toString().indexOf(".") + 1)} %",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CustomPaint(
                        painter: LiquidPainter(
                          _controller.value * maxDuration,
                          maxDuration.toDouble(),
                        ),
                      ),
                    ),
                    CustomPaint(
                        painter: RadialProgressPainter(
                          value: _controller.value * maxDuration,
                          backgroundGradientColors: gradientColors,
                          minValue: 0,
                          maxValue: maxDuration.toDouble(),
                        )),
                  ],
                ),
              );
            }),
        const SizedBox(
          height: 50,
        ),
        // Start and Stop Button
        Container(
          alignment: Alignment.center,
          height: 60,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white54,
                width: 2,
              ),
              shape: BoxShape.circle),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isPlaying) {
                  _controller.reset();
                } else {
                  _controller.reset();
                  _controller.forward();
                }
                isPlaying = !isPlaying;
              });
            },
            child: AnimatedContainer(
              height: isPlaying ? 25 : 60,
              width: isPlaying ? 25 : 60,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isPlaying ? 4 : 100),
                color: Colors.white54,
              ),
            ),
          ),
        )
      ],
    ),
  );
}
*/
