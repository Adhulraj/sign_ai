import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sign_ai/websocket.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';

const btnStyle = ButtonStyle(
    backgroundColor:
        MaterialStatePropertyAll<Color>(Color.fromARGB(255, 18, 214, 240)),
    foregroundColor:
        MaterialStatePropertyAll<Color>(Color.fromARGB(255, 9, 11, 105)));
void main() => runApp(const MaterialApp(
      home: SplashFuturePage(),
      // title: "SignBridge",
    ));

class SplashFuturePage extends StatefulWidget {
  const SplashFuturePage({Key? key}) : super(key: key);

  @override
  _SplashFuturePageState createState() => _SplashFuturePageState();
}
class _SplashFuturePageState extends State<SplashFuturePage> {
  Future<Widget> futureCall() async {
    // do async operation ( api call, auto login)
    return Future.value(const SignTranslate());
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.network(
          'https://cdn4.iconfinder.com/data/icons/logos-brands-5/24/flutter-512.png'),
      title: const Text(
        "Title",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey.shade400,
      showLoader: true,
      loadingText: const Text("Loading..."),
      futureNavigator: futureCall(),
    );
  }
}


class SignTranslate extends StatefulWidget {
  const SignTranslate({Key? key}) : super(key: key);

  @override
  State<SignTranslate> createState() => _SignTranslateState();
}

class _SignTranslateState extends State<SignTranslate> {
  final WebSocket _socket = WebSocket("ws://localhost:5001");
  bool _isConnected = false;
  void connect(BuildContext context) async {
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 15, 30, 44)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => connect(context),
                      style: btnStyle,
                      child: const Text("Connect"),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   style: btnStyle,
                    //   child: const Text("Swap"),
                    // ),
                    ElevatedButton(
                      onPressed: disconnect,
                      style: btnStyle,
                      child: const Text("Disconnect"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _isConnected
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              child: StreamBuilder(
                                stream: _socket.stream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    print('Progrossing');
                                    return const CircularProgressIndicator(
                                      color: Colors.white,
                                    );
                                  } else {
                                    print('No data');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return const Center(
                                      child: Text(
                                        "Connection Closed !",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 28),
                                      ),
                                    );
                                  }
                                  //? Working for single frames
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        child: Image.memory(
                                          Uint8List.fromList(
                                            base64Decode(
                                              (getImage(snapshot)),
                                            ),
                                          ),
                                          gaplessPlayback: true,
                                          excludeFromSemantics: true,
                                        ),
                                      ),
                                      SizedBox(
                                        child: Text(
                                          getText(snapshot),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                        : const Text(
                            "Initiate Connection",
                            style: TextStyle(color: Colors.white, fontSize: 26),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
