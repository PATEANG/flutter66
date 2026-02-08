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

  // ✅ แสดงรูป รองรับ web/mobile
  Widget _roomImage() {
    final img = roomDetails?['image'];
    if (img == null) return const SizedBox();

    const double size = 300;
    final border = Border.all(color: Colors.grey.shade400, width: 2);
    final radius = BorderRadius.circular(12);

    Widget imageWidget;
    if (identical(0, 0.0)) {
      // Flutter web
      imageWidget = Image.network(
        img,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Text('ไม่พบรูปภาพ'),
      );
    } else {
      // Flutter mobile/desktop
      imageWidget = Image.asset(
        img,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: radius,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: border,
                borderRadius: radius,
                color: Colors.white,
              ),
              child: imageWidget,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  // ...existing code...

  List<Widget> _buildFurnitureWidgets(dynamic furnitureData) {
    if (furnitureData == null) return const [Text('-')];
    if (furnitureData is List) {
      return furnitureData.map<Widget>((e) => Text('- $e')).toList();
    }
    return [Text('- $furnitureData')];
  }

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
        elevation: 4,
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
              padding: const EdgeInsets.all(32.0),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.yellow)
                  : error != null
                  ? Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontSize: 20),
                    )
                  : isVacant
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ห้องนี้ว่างอยู่',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'รายละเอียดห้อง',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'จำนวนคนที่ห้องรองรับ: ${roomDetails?['capacity'] ?? '-'}',
                        ),
                        const SizedBox(height: 6),
                        const Text('เฟอร์นิเจอร์:'),
                        ..._buildFurnitureWidgets(roomDetails?['furniture']),
                        const SizedBox(height: 12),
                        _roomImage(), // ✅ รูปอยู่ตรงนี้
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ข้อมูลลูกค้า',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('ชื่อ: ${customer?['name'] ?? '-'}'),
                        Text('เบอร์โทรศัพท์: ${customer?['tel'] ?? '-'}'),
                        Text('พักกี่คน: ${customer?['people'] ?? '-'}'),
                        const SizedBox(height: 12),
                        const Text(
                          'รายละเอียดห้อง',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'จำนวนคนที่ห้องรองรับ: ${roomDetails?['capacity'] ?? '-'}',
                        ),
                        const SizedBox(height: 6),
                        const Text('เฟอร์นิเจอร์:'),
                        ..._buildFurnitureWidgets(roomDetails?['furniture']),
                        const SizedBox(height: 12),
                        _roomImage(), // ✅ รูปอยู่ตรงนี้
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
