// ignore_for_file: file_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sign_ai/websocket.dart';

// import 'package:sign_ai/styles.dart';
const btnStyle = ButtonStyle(
    backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
    foregroundColor: MaterialStatePropertyAll<Color>(Colors.black));
void main() => runApp(const MaterialApp(
      home: SignTranslate(),
      title: "SignBridge",
    ));

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            color: Color.fromARGB(
                255, 48, 110, 151)), //change to Color.fromARGB(255, 15, 30, 44)
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
                      // style: buttonStyle,
                      style: btnStyle,
                      child: const Text("Connect"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: btnStyle,
                      child: const Text("Swap"),
                    ),
                    ElevatedButton(
                      onPressed: disconnect,
                      style: btnStyle,
                      // style: buttonStyle,
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
                              // width: 250,
                              child: StreamBuilder(
                                stream: _socket.stream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    print('Progrossing');
                                    return const CircularProgressIndicator();
                                  } else {
                                    print('No data');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return const Center(
                                      child: Text("Connection Closed !"),
                                    );
                                  }
                                  //? Working for single frames
                                  return Image.memory(
                                    Uint8List.fromList(
                                      base64Decode(
                                        (getImage(snapshot)),
                                      ),
                                    ),
                                    gaplessPlayback: true,
                                    excludeFromSemantics: true,
                                  );
                                },
                              ),
                            ),
                          )
                        : const Text(
                            "Initiate Connection",
                            style: TextStyle(color: Colors.white),
                          ),

                    _isConnected
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 250,
                              height: 250,
                              child: StreamBuilder(
                                stream: _socket.stream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    print('Progrossing');
                                    return const CircularProgressIndicator();
                                  } else {
                                    print('No data');
                                  }

                                  //? Working for single frames
                                  return TextField(
                                    textAlign: TextAlign.start,
                                    key: getText(snapshot),
                                  );
                                },
                              ),
                            ),
                          )
                        : const Text(
                            " ",
                          ),
                    // const Text('Data from server',style: TextStyle(color: Colors.white))
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
  final text = data.split("|")[1];
  print(text);
  return text;
}
