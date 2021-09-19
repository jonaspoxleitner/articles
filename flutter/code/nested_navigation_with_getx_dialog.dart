import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const NestedNavigation());
}

class NestedNavigation extends StatelessWidget {
  const NestedNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nested Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      getPages: <GetPage>[
        GetPage(name: '/dialog', page: () => const DialogWrapper(), fullscreenDialog: true),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
      initialRoute: '/home',
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Navigation')),
      body: const Center(child: Text('Push the button to open the dialog.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/dialog', arguments: 'test'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DialogNavigation {
  DialogNavigation._();

  static const id = 0;

  static const dialogOne = '/dialog-one';
  static const dialogTwo = '/dialog-two';
}

class DialogWrapper extends StatelessWidget {
  const DialogWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(DialogNavigation.id),
      onGenerateRoute: (settings) {
        if (settings.name == DialogNavigation.dialogTwo) {
          return GetPageRoute(
            routeName: DialogNavigation.dialogTwo,
            page: () => DialogScreen(
              id: DialogNavigation.id,
              first: false,
              arguments: settings.arguments,
            ),
          );
        } else {
          return GetPageRoute(
            routeName: DialogNavigation.dialogOne,
            page: () => DialogScreen(
              id: DialogNavigation.id,
              first: true,
              arguments: settings.arguments,
            ),
          );
        }
      },
    );
  }
}

class DialogScreen extends StatelessWidget {
  final int? id;
  final bool first;
  final Object? arguments;

  const DialogScreen({Key? key, this.id, required this.first, this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (first) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('dialog 1'),
          actions: [
            IconButton(icon: const Icon(Icons.clear), onPressed: Get.back),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(DialogNavigation.dialogTwo, id: DialogNavigation.id, arguments: 'test 2'),
          child: const Icon(Icons.chevron_right),
        ),
        body: Center(
          child: Text(
            Get.arguments.toString(),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('dialog 2'),
          actions: [
            IconButton(icon: const Icon(Icons.clear), onPressed: Get.back),
          ],
        ),
        body: Center(
          child: Text(
            arguments.toString(),
          ),
        ),
      );
    }
  }
}
