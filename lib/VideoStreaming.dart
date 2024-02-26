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
  bool signToText = true; // Add this line to declare the signToText flag

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

  void swapMode() {
    setState(() {
      signToText =
          !signToText; // Toggle the signToText flag when the button is pressed
    });
    _socket.send(
        'signToText: $signToText'); // Send the new flag value to the server
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
              ElevatedButton(
                onPressed: swapMode,
                child: const Text("Swap"),
              ),
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
                            var data = base64Decode(snapshot.data.toString());
                            var image = Image.memory(
                              Uint8List.fromList(data),
                              gaplessPlayback: true,
                              excludeFromSemantics: true,
                            );
                            var text = Text('Data from server');

                            // Display the image and text based on the signToText flag
                            return signToText
                                ? Row(children: [image, text])
                                : Row(children: [text, image]);
                          },
                        )
                      : const Text("Initiate Connection"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
