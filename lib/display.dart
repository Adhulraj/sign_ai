import 'package:flutter/material.dart';

class Display extends StatefulWidget {
  bool startBtn;
  bool swapped;
  Color background;
  Widget firstSection;
  Widget secondSection;
  VoidCallback onPressed;

  Display({
    super.key,
    this.startBtn = false,
    this.swapped = false,
    this.firstSection = const Text("First Section"),
    this.secondSection = const Text("Second Section"),
    this.background = const Color.fromARGB(255, 15, 30, 44),
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
                      color: Colors.blue,
                      border: Border.all(
                        color: Colors.blue,
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
                          children: <Widget>[FloatingActionButton(
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
                      color: Colors.blue,
                      border: Border.all(
                        color: Colors.blue,
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
