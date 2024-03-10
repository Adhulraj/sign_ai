// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sign_ai/websocket.dart';
import 'package:sign_ai/easy_splash_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sign_ai/display.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const SplashPage());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(800, 600);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.show();
  });
}

const Color bgColor = Color.fromARGB(255, 9, 23, 39);
const Color fgColor = Color.fromARGB(255, 26, 215, 221);
const Color txtColor = Color.fromARGB(255, 83, 248, 253);

final buttonColors = WindowButtonColors(
    iconNormal: fgColor,
    mouseOver: const Color.fromARGB(255, 27, 64, 107),
    mouseDown: fgColor,
    iconMouseOver: fgColor,
    iconMouseDown: const Color.fromARGB(255, 27, 64, 107));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: fgColor,
    iconMouseOver: Colors.white);

final btnStyle = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
    backgroundColor: const MaterialStatePropertyAll<Color>(bgColor),
    foregroundColor: const MaterialStatePropertyAll<Color>(fgColor));

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

//Code for Splash Screen
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Container(
                color: bgColor,
                child: Column(children: [
                  WindowTitleBarBox(
                      child: Row(children: [
                    Expanded(child: MoveWindow()),
                    const WindowButtons()
                  ])),
                  EasySplashScreen(
                    logo: Image.asset('assets/app_icon.ico'),
                    title: AnimatedTextKit(animatedTexts: [
                      TyperAnimatedText('SignBridge',
                          textStyle: const TextStyle(
                              color: txtColor,
                              fontFamily: 'FFF_Tusj',
                              fontSize: 64))
                    ], isRepeatingAnimation: false),
                    backgroundColor: bgColor,
                    showLoader: false,
                    navigator: const SignTranslate(),
                  )
                ]))));
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Container(
                color: bgColor,
                child: Column(children: [
                  WindowTitleBarBox(
                      child: Row(children: [
                    Expanded(child: MoveWindow()),
                    const WindowButtons()
                  ])),
                  Builder(
                    builder: (context) => SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("SignBridge",
                                  style: TextStyle(
                                      color: txtColor,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w500)),
                              ElevatedButton(
                                onPressed: () => showInfo(context),
                                style: btnStyle,
                                child: const Icon(Icons.info_rounded),
                              )
                            ]),
                      ),
                    ),
                  ),
                  _isConnected
                      ? Flexible(
                          fit: FlexFit.loose,
                          child: StreamBuilder(
                            stream: _socket.stream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                print('Progrossing');
                                return Display(
                                  startBtn: true,
                                  onPressed:
                                      _isConnected ? disconnect : connect,
                                  firstSection: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Display(
                                  onPressed:
                                      _isConnected ? disconnect : connect,
                                  firstSection: const Text(
                                    'Connection Closed',
                                    style: TextStyle(
                                        fontSize: 48, color: txtColor),
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
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 197, 238, 236),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36),
                                ),
                              );
                            },
                          ),
                        )
                      : Flexible(
                          fit: FlexFit.loose,
                          child: Display(
                            onPressed: _isConnected ? disconnect : connect,
                            startBtn: _isConnected,
                          ))
                ]))));
  }
}

void showInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          width: 500.0,
          height: 400.0,
          decoration: const  BoxDecoration(
              color: Color.fromARGB(
                  120, 96, 191, 235),
              borderRadius: BorderRadius.all(Radius.circular(12))), // Adjust this value as needed
          child: const Markdown(data: '''
## The project report is submitted in fulfillment of the requirement for the Bachelor of Computer Science (BSc CS), Calicut University.



Our Sign Language Translator aims to facilitate communication between hearing-impaired and normal hearing individuals. It translates sign language into text, using a camera to capture gestures and machine learning models for interpretation. The system is developed with Flutter for cross-platform UI and Python for backend operations. 

**Group Members:**                   

* Adhulraj K R
* Amal K Jose
* Brinto Varghese
* Neeraj U V

**Under The Guidance of :** Ms. Anagha K J

*Version :* `1.0.0` 
          '''),
        ),
        actions: <Widget>[
          TextButton(
            child: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
