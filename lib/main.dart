import 'package:flutter/material.dart';

import 'presentation/pages/main_page.dart';

import 'package:provider/provider.dart';

import 'package:ulid/ulid.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainAppState(),
      child: MaterialApp(
        home: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // 사용자가 설정한 OS의 텍스트 크기를 무시
              textScaler: TextScaler.noScaling,
            ),
            child: MainPage()),
      ),
    );
  }
}

class MainAppState extends ChangeNotifier {
  var loginState = 0;
  var currentTaskCode = '0000';
  var timeRecordList = [];
  var state = 'stop';
  var duration = Duration();

  void toggle() {
    if (state == 'stop') {
      state = 'start';
      timeRecordList.add([Ulid(), 'start']);
    } else {
      state = 'stop';
      timeRecordList.add([Ulid(), 'stop']);
    }
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MainAppState>();

    Widget page;

    switch (appState.loginState) {
      case 0:
        page = LoginPage();
        break;
      case 1:
        page = WorkPage();
        break;
      default:
        throw UnimplementedError('loginStatus: $appState.loginState');
    }

    return Builder(builder: (context) {
      return Scaffold(
          body: Column(
        children: [
          Text('HELPMATE'),
          page,
        ],
      ));
    });
  }

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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('HELPMATE'),
  //     ),
  //     body: Column(
  //       children: <Widget>[
  //         Padding(
  //           padding: const EdgeInsets.symmetric(
  //             horizontal: 8,
  //             vertical: 16,
  //           ),
  //           child: TextFormField(
  //             decoration: InputDecoration(
  //               border: UnderlineInputBorder(),
  //               labelText: '일감번호를 입력해주세요',
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: onPressed,
  //           child: Text(isStarted ? 'stop' : 'start'),
  //         ),
  //         Text(
  //           convertDurationToString(stopwatch.elapsed),
  //         ),
  //         ElevatedButton(
  //           onPressed: delete,
  //           child: Text('delete'),
  //         ),
  //         ElevatedButton(
  //           onPressed: get,
  //           child: Text('get'),
  //         ),
  //         Text(showMeTheTime),
  //       ],
  //     ),
  //   );
  // }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginForm();
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MainAppState>();

    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }),
            TextFormField(validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Login Success')));

                  appState.loginState = 1;
                }
              },
              child: const Text('Submit'),)
          ],
        ));
  }
}

class WorkPage extends StatelessWidget {
  const WorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
