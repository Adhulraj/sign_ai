// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:flutter/material.dart';

const boxColor = Color.fromARGB(178, 33, 149, 243);

class Display extends StatefulWidget {
  bool startBtn;
  Color background;
  Widget firstSection;
  Widget secondSection;
  VoidCallback onPressed;

  Display({
    super.key,
    this.startBtn = false,
    this.firstSection = const Text("Click Start",
        style: TextStyle(color: Colors.white, fontSize: 28)),
    this.secondSection = const Text(""),
    this.background = const Color.fromARGB(255, 9, 23, 39),
    required this.onPressed,
  });

  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: widget.background,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: boxColor,
                      border: Border.all(
                        color: boxColor,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: Center(
                    child: widget.firstSection,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: widget.onPressed,
                              tooltip: widget.startBtn ? 'Stop' : 'Start',
                              child: Icon(widget.startBtn
                                  ? Icons.stop
                                  : Icons.play_arrow),
                            )
                          ]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: boxColor,
                      border: Border.all(
                        color: boxColor,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: Center(
                    child: widget.secondSection,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
