import 'dart:async';
import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keylogger_with_cpp/const/keyboard_configuration.dart';
import 'dart:io';

import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'const/windows_button_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
      maximumSize: Size(600, 240),
      minimumSize: Size(600, 240),
      size: Size(600, 240),
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: "Shuシュー Keyboard");

  await windowManager.setPosition(const Offset(700, 440));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  KeyloggerController keyloggerController = Get.put(KeyloggerController());
  await keyloggerController.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shuシュー Keyboard',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends GetView<KeyloggerController> {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12.withOpacity(0.2),
      body: WindowBorder(
        color: Colors.black87,
        width: 3,
        child: GestureDetector(
          onDoubleTap: () async {
            await windowManager.setPosition(const Offset(700, 440));
          },
          child: Stack(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.only(top: 22.5, left: 8, right: 8),
                  child: StreamBuilder<String>(
                      stream: controller.consoleStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          controller.refreshString(snapshot.data!.split(' '));
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  children: keyboardListLayer0.map((id) => KeyPad(id: id)).toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  children: keyboardListLayer1.map((id) => KeyPad(id: id)).toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  children: keyboardListLayer2.map((id) => KeyPad(id: id)).toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  children: keyboardListLayer3.map((id) => KeyPad(id: id)).toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  children: keyboardListLayer4.map((id) => KeyPad(id: id)).toList(),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text(
                            'Enter any key to begin!',
                            style: Theme.of(context).textTheme.headlineMedium,
                          );
                        }
                      }),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: WindowTitleBarBox(
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow(child: const SizedBox())),
                      Row(
                        children: [
                          MinimizeWindowButton(colors: buttonColors),
                          CloseWindowButton(colors: closeButtonColors),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeyPad extends GetView<KeyloggerController> {
  const KeyPad({
    super.key,
    required this.id,
    this.width = 40.0,
  });

  final String id;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5.0),
            topRight: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
          ),
          color: controller.keyFromStream.contains(id) ? const Color(0xfff1abb9) : const Color(0xffffffff),
          border: Border.all(width: 3.0, color: const Color(0xfff1abb9).withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              offset: Offset(-5, 5),
              blurRadius: 5,
            ),
          ],
        ),
        //width: width,
        height: 35,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: id == "SPACEBAR"
                  ? 58
                  : id == "SHIFT"
                      ? 12
                      : id == "UP" || id == "ENTER"
                          ? 32
                          : 7),
          child: Center(child: Text(id)),
        ),
      ),
    );
  }
}

class KeyloggerController extends GetxController {
  KeyloggerController();

  late Process process;
  late Stream<List<int>> stdoutStream;
  late Stream<String> consoleStream;

  List<String> keyFromStream = List<String>.empty(growable: true);

  Future<void> initialize() async {
    process = await Process.start('keyboard_screencast.exe', []);
    //process = await Process.start('./keyboard_screencast.exe', []);

    stdoutStream = process.stdout;
    consoleStream = utf8.decoder.bind(stdoutStream);
  }

  void refreshString(List<String> receive) {
    keyFromStream.clear();
    keyFromStream = receive;

    print("receive : $receive");
  }
}
