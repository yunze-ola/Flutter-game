import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
// add one more world this is master line 9 this is finall version. this is final version with testing
//adding somethind a
//Hi from test
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _controller = StreamController<int>.broadcast();

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: StreamBuilder(
        stream: _controller.stream.distinct(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Text("You entered: ${snapshot.data}");
          }
          return Text("waiting for input");
        },
      )),
      body: Stack(
        children: [
          ...List.generate(5, (index) => Puzzle(_controller.stream)),
          Align(
            alignment: Alignment.bottomCenter,
            child: KeyPad(_controller),
          ),
        ],
      ),
    );
  }
}

class KeyPad extends StatelessWidget {
  final StreamController _controller;

  KeyPad(this._controller);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2 / 1,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        return FlatButton(
            onPressed: () {
              _controller.add(index + 1);
            },
            color: Colors.primaries[index][200],
            shape: RoundedRectangleBorder(),
            child: Text("${index + 1}", style: TextStyle(fontSize: 24)));
      }),
    );
  }
}

class Puzzle extends StatefulWidget {
  final Stream<int> inputStream;
  Puzzle(this.inputStream);
  @override
  _PuzzleState createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> with SingleTickerProviderStateMixin {
  int a, b;
  AnimationController _controller;
  Color _color;
  double x;
  Duration myDuration ;

  _reset() {
    a = Random().nextInt(5);
    b = Random().nextInt(5);
    x = Random().nextDouble() * 350;
    
    myDuration = Duration(seconds: Random().nextInt(10) + 6);
    _color = Colors.primaries[Random().nextInt(Colors.primaries.length)][200];
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
     _reset();
     _controller.duration = myDuration;
    _controller.forward(from: 0.0);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _reset();
        _controller.forward(from: 0.0);
      }
    });

    widget.inputStream.listen((int input) {
      if (input == (a + b)) {
        _reset();
        _controller.forward(from: 0.0);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        print("I am building");
        return Positioned(
          left: x,
          top: MediaQuery.of(context).size.height * _controller.value,
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _color.withAlpha(100),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text("$a + $b", style: TextStyle(fontSize: 24)),
          ),
        );
      },
    );
  }
}
