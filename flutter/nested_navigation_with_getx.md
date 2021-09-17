> Important: The following article is based on Flutter 2.5.0 and Get 4.3.8.

# Nested navigation with Getx

Nested navigation is a useful approach when navigation inside a screen is required or when the provided designs require specific transitions to and from the screens. This article will cover the basics for nested navigation in Flutter with the Getx framework.

***

## What is nested navigation?

Have you ever had the challenge to navigate on a screen while still showing the BottomNavigationBar or wanted to navigate inside a dialog? Well, thats what nested navigation is for. With this approach, we can navigate independet from the root navigator of our application. First of all, we have to implement the root navigation for our app by following the Getx docs, which will result in the following `GetMaterialApp`:

```
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
```

Basically, this `MaterialApp` supports the naviation to our `DialogWrapper` and our `HomeScreen'.

## Navigator

Based on the very limited information from the official Getx documentation, we use the nested navigation with a widget called `Navigator` which is already provided by Flutter itself. This widget will be the root of our soon to be implemented dialog flow.

```
// the navigation inside the dialog
class DialogNavigation {
  DialogNavigation._();

  static const id = 0;

  static const firstName = '/first-name';
  static const lastName = '/last-name';
}

// our wrapper, where our main navigation will navigate to
class DialogWrapper extends StatelessWidget {
  const DialogWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(DialogNavigation.id),
      onGenerateRoute: (settings) {
        // navigate to a route by name with settings.name
        if (settings.name == DialogNavigation.lastName) {
          return GetPageRoute(
            routeName: DialogNavigation.lastName,
            page: () => NameScreen(
              id: DialogNavigation.id,
              first: false,
            ),
          );
        } else {
          return GetPageRoute(
            routeName: DialogNavigation.firstName,
            page: () => NameScreen(
              id: DialogNavigation.id,
              first: true,
            ),
          );
        }
      },
    );
  }
}
```

To make it a little bit easier, I created the class `DialogNavigation`, which handles all the available keys for now and also stores the id of the nested navigator. From now on, we can navigate inside the dialog, and we can also close the whole dialog without having to think about the right animation with `Get.back()`. There is also an option to provide an id inside the `Get.back()` function. As you might have already guessed: By providing the `DialogNavigation.id` to the function, we are able to navigate back inside our nested navigation.

## What happended to Get.arguments?

Next, we might want to use Get.arguments, to move data from the current screen to the next one. Unfortunately, Get.arguments only works when using the main navigator inside your application. Here's a simple experiment to show the problems I encountered:

First, we navigate to the dialog with `Get.toNamed('/dialog', arguments: 'test')` and after that, we navigate to the next screen inside the nested naviation with `Get.toNamed(DialogNavigation.lastName, id: DialogNavigation.id, arguments: 'test 2')`. In the following screen recording, you can see, that the second screen also shows 'test'.

### screen recording here

Now it's getting a bit complicated: If Get.arguments doesn't work, how should we then pass arguments between screens? Well, as it turns out, with the RouteSettings in our onGenerateRoute inside the Navigator widget, we are able to use the arguments with settings.arguments, and we're able to pass them als normal parameters to our screens.

```
class DialogWrapper extends StatelessWidget {
  const DialogWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(DialogNavigation.id),
      onGenerateRoute: (settings) {
        if (settings.name == DialogNavigation.lastName) {
          // do error handling here
          print(settings.arguments is String);

          return GetPageRoute(
            routeName: DialogNavigation.lastName,
            page: () => NameScreen(
              id: DialogNavigation.id,
              first: false,
              arguments: settings.arguments,
            ),
          );
        } else {
          return GetPageRoute(
            routeName: DialogNavigation.firstName,
            page: () => NameScreen(
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
```

With this, modification, we can now pass arguments to the screens inside the the nested navigation. As you can see in the code above, you could even do some simple error handling here to redirect to an error screen when the argument is not valid.

## State management

As you may know, state management with Getx is pretty simple when using bindings to push and pop routes. Controllers will then be automatically initialized and disposed when the screen is pushed and poped respecively. This apporoach can also be used with nested navigation, although I recommend using a single controller for your screens inside the nested navigator. In our current code, the GetPage provided inside our GetMaterialApp would look similar to the following code:

```
GetPage(
  name: '/dialog',
  page: () => const DialogWrapper(),
  fullscreenDialog: true,
  binding: BindingsBuilder.put(() => DialogController()),
)
```

The `DialogController` will then be available for all nested routes.

## Full example

***

Thank you so much for reading this article to the end.