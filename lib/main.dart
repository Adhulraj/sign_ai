import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sign_ai/websocket.dart';
import 'package:sign_ai/easy_splash_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sign_ai/display.dart';

void main() => runApp(const MaterialApp(
      home: SplashPage(),
      title: "SignBridge",
    ));

const btnStyle = ButtonStyle(
    backgroundColor:
        MaterialStatePropertyAll<Color>(Color.fromARGB(255, 18, 214, 240)),
    foregroundColor:
        MaterialStatePropertyAll<Color>(Color.fromARGB(255, 9, 11, 105)));

//Code for Splash Screen
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/app_icon.ico'),
      title: AnimatedTextKit(animatedTexts: [
        TyperAnimatedText('SignBridge',
            textStyle: const TextStyle(
                color: Color.fromARGB(255, 37, 213, 236),
                fontFamily: 'FFF_Tusj',
                fontSize: 64))
      ], isRepeatingAnimation: false),
      backgroundColor: const Color.fromARGB(255, 9, 23, 39),
      showLoader: false,
      navigator: const SignTranslate(),
    );
  }
}

//Code for Home page
class SignTranslate extends StatefulWidget {
  const SignTranslate({Key? key}) : super(key: key);

  @override
  State<SignTranslate> createState() => _SignTranslateState();
}

class _SignTranslateState extends State<SignTranslate> {
  final WebSocket _socket = WebSocket("ws://localhost:5001");
  bool _isConnected = false;
  bool _startBtn = false;
  bool _swapped = false;
  void connect() async {
    _socket.connect();
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 30, 44),
          foregroundColor: const Color.fromARGB(255, 72, 196, 228),
          title: const Text(
            "Sign Bridge",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
          ),
        ),
        body: _isConnected
            ? SizedBox(
                child: StreamBuilder(
                  stream: _socket.stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      print('Progrossing');
                      return Display(
                        onPressed: _isConnected ? disconnect : connect,
                        firstSection: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      return Display(
                        onPressed: _isConnected ? disconnect : connect,
                        firstSection: const Text(
                          'Connection Closed',
                          style:
                              TextStyle(fontSize: 48, color: Colors.lightBlue),
                        ),
                      );
                    }
                    //? Working for single frames
                    return Display(
                      startBtn: _isConnected,
                      onPressed: _isConnected ? disconnect : connect,
                      firstSection: Image.memory(
                        Uint8List.fromList(
                          base64Decode(
                            (getImage(snapshot)),
                          ),
                        ),
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                      ),
                      secondSection: Text(
                        getText(snapshot),
                        style: const TextStyle(color: Color.fromARGB(255, 20, 13, 13),fontWeight: FontWeight.bold,fontSize: 36),
                      ),
                    );
                  },
                ),
              )
            : Display(
                onPressed: _isConnected ? disconnect : connect,
                startBtn: _isConnected,
              ));
  }
}

getImage(AsyncSnapshot snapshot) {
  var data = snapshot.data.toString();
  final image = data.split("|")[0];
  return image;
}

getText(AsyncSnapshot snapshot) {
  var data = snapshot.data.toString();
  var text = data.split("|")[1];
  print(text);
  return text;
}
