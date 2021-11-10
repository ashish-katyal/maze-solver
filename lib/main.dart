import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class blockData {
  final Color color;
  final double top;
  final double left;

  blockData(this.color, this.top, this.left);
}

class Block extends StatelessWidget {
  final Color color;
  final double top;
  final double left;

  Block(this.color, this.top, this.left);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        height: 25,
        width: 25,
        color: color,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Color solvedColor = Colors.transparent;
  Color unsolvedColor = Colors.transparent;

  List<blockData> blocks = [];

  List<String> maze = [
    "OOXXOXXXOOXXXXOO",
    "OOOXOOOXOOOXOOOX",
    "OOXOXOXOOOXOXOXO",
    "XOXOOXOXXOOOOOXX",
    "XOOOXXOOXOXOXXOX",
    "OOOOXXOXOOXOOXOX",
    "OOXOOOXOXOXOOXXO",
    "XOOOXOXOXOXOOOOO",
    "OOXOXXOOOOXOXXOO",
    "OOOXOOOXOOOXOOOX",
    "OOXOOOXOXOXXXOXX",
    "XOOOXOXXXXOOOOOX",
    "XXOOXXOOXXOOXXOO",
    "OOXOOXOXOOOOOXXX",
    "OOXOXOXOOOXOOOOO",
    "XXOOXOXXXOXOXXOO",
  ];

  int m = 16;

  int n = 16;

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  bool isSafe(List<String> maze, int i, int j, int m, int n) {
    if (i >= 0 && i < m && j >= 0 && j < n && maze[i][j] == 'O') return true;
    return false;
  }

  Future<bool> solveMaze(List<String> maze, int i, int j, int m, int n) async {
    if (i == m - 1 && j == n - 1) {
      maze[i] = replaceCharAt(maze[i], j, '*');
      await Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          blocks.add(blockData(Colors.green, 100 + i * 25, 100 + j * 25));
          solvedColor = Colors.red;
        });
      });

      exit(0);
    }

    if (isSafe(maze, i, j, m, n)) {
      if (maze[i][j] == '*') return false;

      maze[i] = replaceCharAt(maze[i], j, '*');
      await Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          blocks.add(blockData(Colors.green, 100 + i * 25, 100 + j * 25));
        });
      });

      bool rightSuccess = await solveMaze(maze, i, j + 1, m, n);
      bool downSuccess = await solveMaze(maze, i + 1, j, m, n);
      bool upSuccess = await solveMaze(maze, i - 1, j, m, n);
      bool leftSuccess = await solveMaze(maze, i, j - 1, m, n);

      maze[i] = replaceCharAt(maze[i], j, 'O');
      await Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          blocks.removeWhere((element) => (element.color == Colors.green &&
              element.top == 100 + i * 25 &&
              element.left == 100 + j * 25));
        });
      });

      if (rightSuccess || downSuccess || upSuccess || leftSuccess) {
        return true;
      }
      return false;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < maze.length; i++) {
      for (var j = 0; j < maze[i].length; j++) {
        if ((i == 0 && j == 0) || (i == m - 1 && j == n - 1))
          blocks.add(blockData(Colors.blue, 100 + i * 25, 100 + j * 25));
        else if (maze[i][j] == 'O')
          blocks.add(blockData(Colors.amber, 100 + i * 25, 100 + j * 25));
        else
          blocks.add(blockData(Colors.red, 100 + i * 25, 100 + j * 25));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maze Solver'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'made by - Ashish Katyal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 100),
        ],
        backgroundColor: Colors.redAccent,
        leading: Icon(Icons.code),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          for (var i = 0; i < maze.length; i++) {
            for (var j = 0; j < maze[i].length; j++) {
              if (maze[i][j] == '*') maze[i] = replaceCharAt(maze[i], j, 'O');
            }
          }
          setState(() {
            blocks.removeWhere((element) => (element.color == Colors.green));
            solvedColor = Colors.transparent;
            unsolvedColor = Colors.transparent;
          });
          bool ans = await solveMaze(maze, 0, 0, m, n);
          if (ans == false) {
            setState(() {
              unsolvedColor = Colors.red;
            });
          }
        },
        backgroundColor: Colors.redAccent,
        icon: Icon(Icons.play_arrow),
        label: Text('Solve maze'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          ...blocks.map((blockData) => Block(
                blockData.color,
                blockData.top,
                blockData.left,
              )),
          Positioned(
            top: 150,
            right: 150,
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Problem Statement:',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'A rat starts from source and has to reach the destination. The rat can move only in any direction. In the maze matrix, \'X\' means the block is a dead end and \'O\' means the block can be used in the path from source to destination.',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Here is a maze solver which uses Recursion and Backtracking to solve the maze. The \'X\' is represented by red blocks which means dead end and \'O\' is represented by yellow blocks which can be used as path by the rat. The blue blocks represent source and destination of the maze.',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Made with Flutter and Dart',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 200,
            child: Text(
              'Maze solved',
              style: TextStyle(
                color: solvedColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 120,
            child: Text(
              'Maze can\'t be solved',
              style: TextStyle(
                color: unsolvedColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
