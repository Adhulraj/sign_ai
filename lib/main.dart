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
  final WebSocket _socket = WebSocket("ws://192.168.1.5:5000");
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          "Sign Bridge",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
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
                      child: const Text("Swap"),
                      style: btnStyle,
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
                              width: 250,
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
                                        (snapshot.data.toString()),
                                      ),
                                    ),
                                    gaplessPlayback: true,
                                    excludeFromSemantics: true,
                                  );
                                },
                              ),
                            ),
                        )
                        : const Text("Initiate Connection",style: TextStyle(color: Colors.white), ),
                    const Text('Data from server',style: TextStyle(color: Colors.white))
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
