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
        // '/page2': (context) => const Page2(), // Removed: Page2 requires roomNumber
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
              color: Colors.white,
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
              color: const Color(0xFFEDE7F6),
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
                                border: Border.all(color: Colors.deepPurple, width: 2),
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่อลูกค้า'),
                onChanged: (v) => setState(() => name = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
                keyboardType: TextInputType.phone,
                onChanged: (v) => setState(() => phone = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'พักกี่คน'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => people = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ห้องอะไร'),
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
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('บันทึก', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}