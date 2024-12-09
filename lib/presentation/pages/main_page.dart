import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isStarted = false;
  final stopwatch = Stopwatch();
  late Timer timer;
  static const host = 'http://10.0.192.15:8000';
  String showMeTheTime = '';

  Future<void> getTime() async {
    try {
      http.Response res = await http.get(Uri.parse('$host/time'));
      Map<String, dynamic> json = jsonDecode(res.body);
      print(json['body']);
      showMeTheTime = json['body']['time'];
    } catch (e) {
      //
    }
  }

  Future<void> postTime() async {
    try {
      http.Response res = await http
          .post(Uri.parse('$host/time?timestamp=${DateTime.now().toUtc()}'));
      var json = jsonDecode(res.body);
      print("post");
    } catch (e) {
      //
    }
  }

  Future<void> deleteTime() async {
    try {
      http.Response res = await http.delete(Uri.parse('$host/time'));
      var json = jsonDecode(res.body);
      print("delete");
      showMeTheTime = '';
    } catch (e) {
      //
    }
  }

  Future<void> get() async {
    await getTime();
    setState(() {});
  }

  Future<void> post() async {
    await postTime();
  }

  Future<void> delete() async {
    await deleteTime();
    stopwatch.reset();
    setState(() {});
  }

  void onPressed() async {
    if (isStarted) {
      await post();
      stopwatch.stop();
      timer.cancel();
    } else {
      await post();
      stopwatch.start();
      timer = Timer.periodic(
        Duration(
          milliseconds: 10,
        ),
        (t) {
          setState(() {});
        },
      );
    }
    isStarted = !isStarted;
  }

  String convertDurationToString(Duration d) {
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ms = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');

    return "$hh:$mm:$ss:$ms";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HELPMATE'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '일감번호를 입력해주세요',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(isStarted ? 'stop' : 'start'),
          ),
          Text(
            convertDurationToString(stopwatch.elapsed),
          ),
          ElevatedButton(
            onPressed: delete,
            child: Text('delete'),
          ),
          ElevatedButton(
            onPressed: get,
            child: Text('get'),
          ),
          Text(showMeTheTime),
        ],
      ),
    );
  }
}
