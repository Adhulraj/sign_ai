// ignore_for_file: file_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sign_ai/websocket.dart';
// import 'package:sign_ai/styles.dart';

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
  final WebSocket _socket = WebSocket("ws://localhost:5000");
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
        title: const Text("Translate Sign"),
      ),
      body: Padding(
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
                    child: const Text("Connect"),
                  ),
                  ElevatedButton(
                    onPressed: disconnect,
                    // style: buttonStyle,
                    child: const Text("Disconnect"),
                  ),
                ],
              ),
              ElevatedButton(onPressed: (){}, child: const Text("Swap")),
              Row(
                children: [
                  const SizedBox(
                    height: 50.0,
                    width: 50.0,
                  ),
                  _isConnected
                      ? StreamBuilder(
                          stream: _socket.stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              print('Progrossing');
                              return const CircularProgressIndicator();
                            }
                            else{
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
                        )
                      : const Text("Initiate Connection")
                      ,const Text('Data from server')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
