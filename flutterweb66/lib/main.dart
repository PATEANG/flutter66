import 'package:flutter/material.dart';
import 'package:flutterweb66/page2.dart';
import 'package:flutterweb66/loginStaff.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        '/': (context) => const SplitScreen(),
        '/main': (context) => const MainFormScreen(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.yellow[700]!,
          onPrimary: Colors.black,
          secondary: Colors.black,
          onSecondary: Colors.yellow[700]!,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.black,
          onBackground: Colors.yellow[700]!,
          surface: Colors.yellow[50]!,
          onSurface: Colors.black,
        ),
        primaryColor: Colors.yellow[700],
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.yellow,
          iconTheme: IconThemeData(color: Colors.yellow),
          titleTextStyle: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.yellow[700],
            side: BorderSide(color: Colors.yellow[700]!),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.yellow),
          bodySmall: TextStyle(color: Colors.yellow),
          titleLarge: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.yellow[700]),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
        ),
      ),
    );
  }
}

// --- SplitScreen: left = login/main, right = 10 boxes ---
class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});
  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  bool isLoggedIn = false;

  void onLoginSuccess() {
    setState(() {
      isLoggedIn = true;
    });
  }

  List<bool> roomBooked = List.generate(10, (index) => false); // false = ว่าง, true = จองแล้ว
  bool loadingRooms = false;

  @override
  void initState() {
    super.initState();
    fetchRoomStatus();
  }

  Future<void> fetchRoomStatus() async {
    setState(() { loadingRooms = true; });
    try {
      final url = Uri.parse('http://localhost/customer/room_status.php');
      final response = await http.get(url);
      final resp = jsonDecode(response.body);
      if (resp['rooms'] is List) {
        setState(() {
          roomBooked = List<bool>.from(resp['rooms']);
        });
      } else if (resp['rooms'] is Map) {
        setState(() {
          for (int i = 0; i < 10; i++) {
            roomBooked[i] = resp['rooms']['${i+1}'] ?? false;
          }
        });
      }
    } catch (e) {
      // error, ไม่เปลี่ยนสี
    }
    setState(() { loadingRooms = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side: login or main form
          Expanded(
            flex: 2,
            child: Container(
              color: const Color.fromARGB(255, 221, 221, 221),
              child: Center(
                child: isLoggedIn
                    ? MainFormScreen(onSaved: fetchRoomStatus)
                    : LoginStaff(onLogin: onLoginSuccess),
              ),
            ),
          ),
          // Right side: 10 room boxes (2 rows x 5 cols)
          Expanded(
            flex: 3,
            child: Container(
              color: const Color.fromARGB(255, 221, 221, 221),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: loadingRooms
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 5,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      children: List.generate(10, (index) {
                        final booked = roomBooked[index];
                        final disabled = !isLoggedIn;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: disabled
                              ? null
                              : () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Page2(roomNumber: index + 1),
                                    ),
                                  );
                                  if (result == true) {
                                    fetchRoomStatus();
                                  }
                                },
                          child: Opacity(
                            opacity: disabled ? 0.5 : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: booked ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  'Room ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- MainFormScreen: customer info form ---
class MainFormScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  const MainFormScreen({super.key, this.onSaved});
  @override
  State<MainFormScreen> createState() => _MainFormScreenState();
}

class _MainFormScreenState extends State<MainFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String people = '';
  String room = '';

  Future<void> _submitData() async {
    final url = Uri.parse('http://localhost/customer/save_customer.php');
    final data = {
      'name': name,
      'tel': phone,
      'people': int.tryParse(people) ?? 0,
      'room': room,
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      final resp = jsonDecode(response.body);
      if (resp['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
        );
        if (widget.onSaved != null) widget.onSaved!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${resp['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เชื่อมต่อ backend ไม่สำเร็จ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ลงทะเบียนลูกค้า',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 24),
              TextFormField(
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'ชื่อลูกค้า',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                ),
                onChanged: (v) => setState(() => name = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (v) => setState(() => phone = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'พักกี่คน',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => people = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'ห้องอะไร',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                ),
                onChanged: (v) => setState(() => room = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('บันทึก', style: TextStyle(fontSize: 18, color: Colors.yellow)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}