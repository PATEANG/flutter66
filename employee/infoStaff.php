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

$conn = new mysqli('localhost', 'root', '', 'hotel_app');
if ($conn->connect_error) {
	echo json_encode(['status' => 'error', 'message' => 'เชื่อมต่อฐานข้อมูลล้มเหลว']);
	exit;
}

$data = json_decode(file_get_contents('php://input'), true);
$action = $data['action'] ?? '';
$username = $data['username'] ?? '';
$password = $data['password'] ?? '';

if ($action === 'register') {
	// สมัครพนักงานใหม่
	if (!$username || !$password) {
		echo json_encode(['status' => 'error', 'message' => 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน']);
		exit;
	}
	// ตรวจสอบว่ามี username นี้อยู่แล้วหรือยัง
	$stmt = $conn->prepare('SELECT id FROM employees WHERE username=?');
	$stmt->bind_param('s', $username);
	$stmt->execute();
	$stmt->store_result();
	if ($stmt->num_rows > 0) {
		echo json_encode(['status' => 'error', 'message' => 'มีผู้ใช้นี้อยู่แล้ว']);
		$stmt->close();
		$conn->close();
		exit;
	}
	$stmt->close();
	// สมัครใหม่
	$stmt = $conn->prepare('INSERT INTO employees (username, password) VALUES (?, ?)');
	$stmt->bind_param('ss', $username, $password);
	if ($stmt->execute()) {
		echo json_encode(['status' => 'success', 'message' => 'สมัครพนักงานสำเร็จ']);
	} else {
		echo json_encode(['status' => 'error', 'message' => 'สมัครพนักงานไม่สำเร็จ']);
	}
	$stmt->close();
	$conn->close();
	exit;
}

if ($action === 'login') {
	// ล็อกอิน
	if (!$username || !$password) {
		echo json_encode(['status' => 'error', 'message' => 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน']);
		exit;
	}
	$stmt = $conn->prepare('SELECT id FROM employees WHERE username=? AND password=?');
	$stmt->bind_param('ss', $username, $password);
	$stmt->execute();
	$stmt->store_result();
	if ($stmt->num_rows > 0) {
		echo json_encode(['status' => 'success', 'message' => 'ล็อกอินสำเร็จ']);
	} else {
		echo json_encode(['status' => 'error', 'message' => 'ไม่มีผู้ใช้นี้ในระบบ']);
	}
	$stmt->close();
	$conn->close();
	exit;
}

echo json_encode(['status' => 'error', 'message' => 'ไม่พบ action ที่ร้องขอ']);
exit;
