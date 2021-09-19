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
      title: 'Nested Navigation - BNB',
      theme: ThemeData(primarySwatch: Colors.blue),
      getPages: <GetPage>[
        GetPage(name: '/settings', page: () => const SettingsWrapper(), fullscreenDialog: true),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
      initialRoute: '/home',
      initialBinding: BindingsBuilder.put(() => HomeController()),
    );
  }
}

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.state.value == HomeState.home ? 0 : 1,
            onTap: (index) => index == 0 ? controller.selectHome() : controller.selectSettings(),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
          body: Builder(
            builder: (context) {
              switch (controller.state.value) {
                case HomeState.home:
                  return Scaffold(
                    appBar: AppBar(title: const Text('BottomNavigationBar')),
                    body: const Center(child: Text('Home')),
                  );
                case HomeState.settings:
                  return const SettingsWrapper();
              }
            },
          ),
        ));
  }
}

enum HomeState { home, settings }

class HomeController extends GetxController {
  final state = HomeState.home.obs;

  void selectHome() => state.value = HomeState.home;
  Future<void> selectSettings() async {
    if (state.value == HomeState.settings) {
      try {
        await Get.keys[SettingsNavigation.id]!.currentState!.maybePop();
      } catch (e) {
        // error
      }
    }
    state.value = HomeState.settings;
  }
}

class SettingsNavigation {
  SettingsNavigation._();

  static const id = 0;

  static const settings = '/settings';
  static const dialog = '/dialog';
}

class SettingsWrapper extends StatelessWidget {
  const SettingsWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(SettingsNavigation.id),
      onGenerateRoute: (settings) {
        if (settings.name == SettingsNavigation.dialog) {
          return GetPageRoute(
            routeName: SettingsNavigation.dialog,
            page: () => const SettingsScreen(id: SettingsNavigation.id, first: false),
          );
        } else {
          return GetPageRoute(
            routeName: SettingsNavigation.settings,
            page: () => const SettingsScreen(id: SettingsNavigation.id, first: true),
          );
        }
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final int? id;
  final bool first;

  const SettingsScreen({Key? key, this.id, required this.first}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (first) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Settings'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(SettingsNavigation.dialog, id: SettingsNavigation.id),
          child: const Icon(Icons.chevron_right),
        ),
        body: const Center(child: Text('Main Settings')),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Detail'),
        ),
        body: const Center(child: Text('Detail Settings')),
      );
    }
  }
}
