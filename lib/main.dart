import 'package:flutter/material.dart';
import 'screens/all_players.dart';
import 'services/storage.dart';
import 'models/player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // create an in-memory storage and seed it with sample players
    final storage = PlayerStorage();
    final sample = <Player>[
      Player(id: '', nickname: 'Ace', fullName: 'Miguel Santos', contact: '09171234567', email: 'miguel.santos@example.com', address: '45 Rizal Ave, Cebu', remarks: 'Left-handed attacker', levelStart: 3, levelEnd: 8),
      Player(id: '', nickname: 'SmashPro', fullName: 'Jonah Reyes', contact: '09179876543', email: 'jonah.reyes@example.com', address: '12 Mabini St, Davao', remarks: 'Powerful smash', levelStart: 9, levelEnd: 14),
      Player(id: '', nickname: 'NetMaster', fullName: 'Isabella Cruz', contact: '09201239876', email: 'isabella.cruz@example.com', address: '88 Lopez Rd, Iloilo', remarks: 'Excellent net play', levelStart: 6, levelEnd: 9),
      Player(id: '', nickname: 'Dart', fullName: 'Rafael Gomez', contact: '09172223344', email: 'rafael.gomez@example.com', address: '3 Mango Lane, Bohol', remarks: 'Quick footwork', levelStart: 0, levelEnd: 4),
      Player(id: '', nickname: 'SpinKing', fullName: 'Carlos Rivera', contact: '09173334455', email: 'carlos.rivera@example.com', address: '7 Pine St, Quezon City', remarks: 'Great racket spin', levelStart: 12, levelEnd: 18),
      Player(id: '', nickname: 'Runner', fullName: 'Jasmine Lee', contact: '09174445566', email: 'jasmine.lee@example.com', address: '21 Oak Blvd, Batangas', remarks: 'Endurance specialist', levelStart: 6, levelEnd: 10),
      Player(id: '', nickname: 'Finesse', fullName: 'Aaron Lim', contact: '09175556677', email: 'aaron.lim@example.com', address: '4 Palm St, Laguna', remarks: 'Tactical player', levelStart: 9, levelEnd: 12),
      Player(id: '', nickname: 'Shadow', fullName: 'Natalie Mendoza', contact: '09176667788', email: 'natalie.mendoza@example.com', address: '99 Bayview, Iloilo', remarks: 'Defensive specialist', levelStart: 3, levelEnd: 6),
      Player(id: '', nickname: 'Flash', fullName: 'Eric Tan', contact: '09177778899', email: 'eric.tan@example.com', address: '56 Hill Rd, Cebu', remarks: 'Very fast reflexes', levelStart: 0, levelEnd: 3),
      Player(id: '', nickname: 'Eagle', fullName: 'Monica Dela Cruz', contact: '09178889900', email: 'monica.delacruz@example.com', address: '10 Sunrise Ave, Manila', remarks: 'Strong overhead shots', levelStart: 15, levelEnd: 20),
    ];
    for (final p in sample) {
      storage.add(p);
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: AllPlayersScreen(storage: storage),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
