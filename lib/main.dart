import 'package:flutter/material.dart';
import 'screens/all_players.dart';
import 'services/storage.dart';
import 'models/player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = PlayerStorage();
    final samplePlayers = <Player>[
      Player(
        id: '',
        nickname: 'Ace',
        fullName: 'Miguel Santos',
        contact: '09171234567',
        email: 'miguel.santos@example.com',
        address: '45 Rizal Ave, Cebu',
        remarks: 'Left-handed attacker',
        levelStart: 3,
        levelEnd: 8,
      ),
      Player(
        id: '',
        nickname: 'SmashPro',
        fullName: 'Jonah Reyes',
        contact: '09179876543',
        email: 'jonah.reyes@example.com',
        address: '12 Mabini St, Davao',
        remarks: 'Powerful smash',
        levelStart: 9,
        levelEnd: 14,
      ),
      Player(
        id: '',
        nickname: 'NetMaster',
        fullName: 'Isabella Cruz',
        contact: '09201239876',
        email: 'isabella.cruz@example.com',
        address: '88 Lopez Rd, Iloilo',
        remarks: 'Excellent net play',
        levelStart: 6,
        levelEnd: 9,
      ),
      Player(
        id: '',
        nickname: 'Dart',
        fullName: 'Rafael Gomez',
        contact: '09172223344',
        email: 'rafael.gomez@example.com',
        address: '3 Mango Lane, Bohol',
        remarks: 'Quick footwork',
        levelStart: 0,
        levelEnd: 4,
      ),
      Player(
        id: '',
        nickname: 'SpinKing',
        fullName: 'Carlos Rivera',
        contact: '09173334455',
        email: 'carlos.rivera@example.com',
        address: '7 Pine St, Quezon City',
        remarks: 'Great racket spin',
        levelStart: 12,
        levelEnd: 18,
      ),
      Player(
        id: '',
        nickname: 'Runner',
        fullName: 'Jasmine Lee',
        contact: '09174445566',
        email: 'jasmine.lee@example.com',
        address: '21 Oak Blvd, Batangas',
        remarks: 'Endurance specialist',
        levelStart: 6,
        levelEnd: 10,
      ),
    ];

    for (final player in samplePlayers) {
      storage.add(player);
    }

    return MaterialApp(
      title: 'Badminton Player Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: AllPlayersScreen(storage: storage),
    );
  }
}
