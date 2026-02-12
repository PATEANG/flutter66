<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// รองรับ preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
	http_response_code(200);
	exit;
}

// เชื่อมต่อฐานข้อมูล (แก้ไขค่าตามจริง)
$conn = new mysqli('localhost', 'root', '', 'hotel_app'); // ใช้ชื่อฐานข้อมูลจริง
if ($conn->connect_error) {
	echo json_encode(['status' => 'error', 'message' => 'เชื่อมต่อฐานข้อมูลล้มเหลว']);
	exit;
}

// รับข้อมูล JSON
$data = json_decode(file_get_contents('php://input'), true);
$room = $data['room'] ?? null;
$name = $data['name'] ?? null;
$tel = $data['tel'] ?? null;
$people = $data['people'] ?? null;

if (!$room || !$name || !$tel || !$people) {
	echo json_encode(['status' => 'error', 'message' => 'ข้อมูลไม่ครบถ้วน']);
	exit;
}

// เตรียมคำสั่ง SQL (ใช้ชื่อตาราง customer_records)
$stmt = $conn->prepare("UPDATE customer_records SET name=?, tel=?, people=? WHERE room=?");
$stmt->bind_param("ssis", $name, $tel, $people, $room);

if ($stmt->execute()) {
	echo json_encode(['status' => 'success']);
} else {
	echo json_encode(['status' => 'error', 'message' => 'อัปเดตข้อมูลไม่สำเร็จ']);
}

$stmt->close();
$conn->close();
?>
