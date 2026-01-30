import 'package:flutter/material.dart';
import 'package:flutterweb66/page2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/page2': (context) => const Page2(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title; // เรารักกันนะครับจุ๊ฐๆๆๆๆๆๆเรารักกันนะครับจุ๊ฐๆๆๆๆๆๆเรารักกันนะครับจุ๊ฐๆๆๆๆๆๆเรารักกันนะครับจุ๊ฐๆๆๆๆๆๆเรารักกันนะครับจุ๊ฐๆๆๆๆๆๆเรารักกันนะครับจุ๊ฐๆๆๆๆๆๆเรารักกันนะครับจุ๊ฐๆๆๆๆๆๆ
 // เกจัดออยเอ้ย
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าแรก', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You have pushed the button this many times:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _incrementCounter,
                        icon: const Icon(Icons.add),
                        label: const Text('เพิ่มจำนวน'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/page2');
                        },
                        icon: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                        label: const Text('ไปหน้า 2', style: TextStyle(color: Colors.deepPurple)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurple, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
