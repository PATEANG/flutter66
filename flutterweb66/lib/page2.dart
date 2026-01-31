  // ...existing code...
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Page2 extends StatefulWidget {
  final int roomNumber;
  const Page2({super.key, required this.roomNumber});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {

      Future<void> editCustomerDialog() async {
        if (customer == null) return;
        final nameController = TextEditingController(text: customer?['name'] ?? '');
        final telController = TextEditingController(text: customer?['tel'] ?? '');
        final peopleController = TextEditingController(text: customer?['people']?.toString() ?? '');
        bool saving = false;
        String? errorMsg;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('แก้ไขข้อมูลลูกค้า'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'ชื่อ'),
                      ),
                      TextField(
                        controller: telController,
                        decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextField(
                        controller: peopleController,
                        decoration: const InputDecoration(labelText: 'พักกี่คน'),
                        keyboardType: TextInputType.number,
                      ),
                      if (errorMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(context),
                      child: const Text('ยกเลิก'),
                    ),
                    ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setState(() { saving = true; errorMsg = null; });
                              final url = Uri.parse('http://localhost/customer/update_customer.php');
                              try {
                                final response = await http.post(
                                  url,
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'room': widget.roomNumber,
                                    'name': nameController.text.trim(),
                                    'tel': telController.text.trim(),
                                    'people': int.tryParse(peopleController.text.trim()) ?? 1,
                                  }),
                                );
                                final resp = jsonDecode(response.body);
                                if (resp['status'] == 'success') {
                                  Navigator.pop(context, true);
                                } else {
                                  setState(() { errorMsg = resp['message'] ?? 'เกิดข้อผิดพลาด'; });
                                }
                              } catch (e) {
                                setState(() { errorMsg = 'บันทึกข้อมูลไม่สำเร็จ: $e'; });
                              }
                              setState(() { saving = false; });
                            },
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('บันทึก'),
                    ),
                  ],
                );
              },
            );
          },
        ).then((result) async {
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
            );
            await fetchRoomInfo();
          }
        });
      }
    Future<void> deleteCustomer() async {
      final url = Uri.parse('http://localhost/customer/delete_customer.php');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'room': widget.roomNumber}),
        );
        final resp = jsonDecode(response.body);
        if (resp['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลบข้อมูลเรียบร้อย')),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context, true); // กลับไป main พร้อมบอกให้ refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: ${resp['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบข้อมูลไม่สำเร็จ: $e')),
        );
      }
    }
  bool loading = true;
  Map<String, dynamic>? customer;
  bool isVacant = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchRoomInfo();
  }

  Future<void> fetchRoomInfo() async {
    setState(() { loading = true; error = null; });
    try {
      final url = Uri.parse('http://localhost/customer/room_status.php?detail=${widget.roomNumber}');
      final response = await http.get(url);
      final resp = jsonDecode(response.body);
      if (resp['customer'] != null) {
        setState(() {
          customer = resp['customer'];
          isVacant = false;
        });
      } else if (resp['vacant'] == true) {
        setState(() {
          customer = null;
          isVacant = true;
        });
      } else {
        setState(() {
          error = 'ไม่พบข้อมูลห้อง';
        });
      }
    } catch (e) {
      setState(() { error = 'เกิดข้อผิดพลาด: $e'; });
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: loading
                  ? const CircularProgressIndicator()
                  : error != null
                      ? Text(error!, style: const TextStyle(color: Colors.red, fontSize: 20))
                      : isVacant
                          ? const Text('ห้องนี้ว่างอยู่', style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold))
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ข้อมูลลูกค้า', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                const SizedBox(height: 16),
                                Text('ชื่อ: ${customer?['name'] ?? '-'}', style: const TextStyle(fontSize: 18)),
                                Text('เบอร์โทรศัพท์: ${customer?['tel'] ?? '-'}', style: const TextStyle(fontSize: 18)),
                                Text('พักกี่คน: ${customer?['people'] ?? '-'}', style: const TextStyle(fontSize: 18)),
                                Text('ห้อง: ${customer?['room'] ?? '-'}', style: const TextStyle(fontSize: 18)),
                                if (customer?['recorded_at'] != null)
                                  Text('เวลาจอง: ${customer?['recorded_at']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        editCustomerDialog();
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('แก้ไขข้อมูล'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('ยืนยันการลบข้อมูล'),
                                            content: const Text('คุณต้องการลบข้อมูลลูกค้าห้องนี้ใช่หรือไม่?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('ยกเลิก'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('ลบ'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await deleteCustomer();
                                        }
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text('ลบข้อมูล'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
