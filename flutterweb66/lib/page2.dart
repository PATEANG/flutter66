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
    // ---------- EDIT CUSTOMER ----------
    Future<void> editCustomer() async {
      final nameController = TextEditingController(text: customer?['name'] ?? '');
      final telController = TextEditingController(text: customer?['tel'] ?? '');
      final peopleController = TextEditingController(text: customer?['people']?.toString() ?? '');

      final formKey = GlobalKey<FormState>();
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('แก้ไขข้อมูลลูกค้า'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'ชื่อ'),
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อ' : null,
                ),
                TextFormField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
                ),
                TextFormField(
                  controller: peopleController,
                  decoration: const InputDecoration(labelText: 'พักกี่คน'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกจำนวนคน' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;
                try {
                  final url = Uri.parse('http://localhost/customer/update_customer.php');
                  final data = {
                    'room': widget.roomNumber,
                    'name': nameController.text,
                    'tel': telController.text,
                    'people': int.tryParse(peopleController.text) ?? 0,
                  };
                  final resp = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(data),
                  );
                  final json = jsonDecode(resp.body);
                  if (json['status'] == 'success') {
                    if (mounted) Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('แก้ไขไม่สำเร็จ: \\${json['message']}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('แก้ไขไม่สำเร็จ: $e')),
                  );
                }
              },
              child: const Text('บันทึก', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
      if (result == true) {
        await fetchRoomInfo();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('แก้ไขข้อมูลเรียบร้อย')),
        );
      }
    }
  static const Map<int, Map<String, dynamic>> _defaultRoomDetails = {
    1: {
      'capacity': 2,
      'furniture': ['เตียงคู่', 'ตู้เสื้อผ้า', 'โต๊ะ'],
      'image': 'assets/Room1.png',
    },
    2: {
      'capacity': 3,
      'furniture': ['เตียงเดี่ยว', 'ตู้เล็ก', 'เก้าอี้'],
      'image': 'assets/Room2.png',
    },
    3: {
      'capacity': 2,
      'furniture': ['เตียงคู่', 'ทีวี'],
      'image': 'assets/Room3.png',
    },
    4: {
      'capacity': 4,
      'furniture': ['เตียงสองชั้น', 'โต๊ะ', 'ตู้'],
      'image': 'assets/Room4.png',
    },
    5: {
      'capacity': 1,
      'furniture': ['เตียงเดี่ยว'],
      'image': 'assets/Room5.png',
    },
    6: {
      'capacity': 2,
      'furniture': ['เตียงคู่', 'ตู้เสื้อผ้า', 'โต๊ะ'],
      'image': 'assets/Room6.png',
    },
    7: {
      'capacity': 3,
      'furniture': ['เตียงเดี่ยว', 'ตู้เล็ก', 'เก้าอี้'],
      'image': 'assets/Room7.png',
    },
    8: {
      'capacity': 2,
      'furniture': ['เตียงคู่', 'ทีวี'],
      'image': 'assets/Room8.png',
    },
    9: {
      'capacity': 4,
      'furniture': ['เตียงสองชั้น', 'โต๊ะ', 'ตู้'],
      'image': 'assets/Room9.png',
    },
    10: {
      'capacity': 1,
      'furniture': ['เตียงเดี่ยว'],
      'image': 'assets/Room10.png',
    },
  };

  bool loading = true;
  Map<String, dynamic>? customer;
  Map<String, dynamic>? roomDetails;
  bool isVacant = false;
  String? error;

  // ---------- TEXT STYLES ----------
  final titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final sectionStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  final labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  final valueStyle = const TextStyle(
    fontSize: 16,
    height: 1.4,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    fetchRoomInfo();
  }

  Future<void> fetchRoomInfo() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final url = Uri.parse(
        'http://localhost/customer/room_status.php?detail=${widget.roomNumber}',
      );
      final response = await http.get(url);
      final resp = jsonDecode(response.body);

      roomDetails = resp['room_details'] ?? resp['details'] ?? resp['roomInfo'];
      roomDetails ??= _defaultRoomDetails[widget.roomNumber];

      if (resp['customer'] != null) {
        customer = resp['customer'];
        isVacant = false;
      } else if (resp['vacant'] == true) {
        customer = null;
        isVacant = true;
      } else {
        error = 'ไม่พบข้อมูลห้อง';
      }
    } catch (e) {
      error = 'เกิดข้อผิดพลาด: $e';
    }

    setState(() {
      loading = false;
    });
  }

  // ---------- DELETE CUSTOMER ----------
  Future<void> deleteCustomer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('ต้องการลบการเข้าใช้ห้องนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse('http://localhost/customer/delete_customer.php');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'room': widget.roomNumber}),
      );

      // กลับไปหน้าลงทะเบียนลูกค้า และแจ้งให้ refresh
      if (mounted) {
        Navigator.pop(context, true); // ส่ง true เพื่อให้หน้าหลัก fetch ใหม่
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
    }
  }

  // ---------- UI HELPERS ----------
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: valueStyle,
          children: [
            TextSpan(text: '$label: ', style: labelStyle),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFurnitureWidgets(dynamic furnitureData) {
    if (furnitureData == null) {
      return [Text('-', style: valueStyle)];
    }

    if (furnitureData is List) {
      return furnitureData
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $e', style: valueStyle),
            ),
          )
          .toList();
    }

    return [Text('• $furnitureData', style: valueStyle)];
  }

  Widget _roomImage() {
    final img = roomDetails?['image'];
    if (img == null) return const SizedBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(img, width: 300, height: 300, fit: BoxFit.cover),
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Room ${widget.roomNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.grey[300],
        child: Center(
          child: Card(
            color: Colors.yellow[50],
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT : TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isVacant) ...[
                            Text('ข้อมูลลูกค้า', style: titleStyle),
                            const SizedBox(height: 16),
                            _infoRow('ชื่อ', customer?['name'] ?? '-'),
                            _infoRow('เบอร์โทรศัพท์', customer?['tel'] ?? '-'),
                            _infoRow(
                              'พักกี่คน',
                              '${customer?['people'] ?? '-'}',
                            ),
                            const SizedBox(height: 28),
                          ] else ...[
                            Text(
                              'ห้องนี้ว่างอยู่',
                              style: titleStyle.copyWith(color: Colors.green),
                            ),
                            const SizedBox(height: 28),
                          ],
                          Text('รายละเอียดห้อง', style: sectionStyle),
                          const SizedBox(height: 12),
                          _infoRow(
                            'จำนวนคนที่รองรับ',
                            '${roomDetails?['capacity'] ?? '-'} คน',
                          ),
                          const SizedBox(height: 12),
                          Text('เฟอร์นิเจอร์', style: labelStyle),
                          const SizedBox(height: 6),
                          ..._buildFurnitureWidgets(roomDetails?['furniture']),
                        ],
                      ),
                    ),

                    const SizedBox(width: 32),

                    // RIGHT : IMAGE + DELETE/EDIT BUTTON
                    Column(
                      children: [
                        _roomImage(),
                        const SizedBox(height: 16),

                        if (!isVacant)
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: editCustomer,
                                icon: const Icon(Icons.edit),
                                label: const Text('แก้ไขข้อมูล'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: deleteCustomer,
                                icon: const Icon(Icons.delete),
                                label: const Text('ลบการเข้าใช้ห้อง'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
