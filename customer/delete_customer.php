<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// รับข้อมูล JSON
$data = json_decode(file_get_contents('php://input'), true);
if (!isset($data['room'])) {
	echo json_encode(["status" => "error", "message" => "Missing room number"]);
	exit;
}
$roomNum = intval($data['room']);

$conn = new mysqli("localhost", "root", "", "hotel_app");
if ($conn->connect_error) {
	echo json_encode(["status" => "error", "message" => $conn->connect_error]);
	exit;
}

// ลบ record ล่าสุดของห้องนี้ (ถ้ามี)
$sql = "SELECT id FROM customer_records WHERE room = '$roomNum' ORDER BY id DESC LIMIT 1";
$result = $conn->query($sql);
if ($result && $row = $result->fetch_assoc()) {
	$id = intval($row['id']);
	$del = $conn->query("DELETE FROM customer_records WHERE id = $id");
	if ($del) {
		echo json_encode(["status" => "success"]);
	} else {
		echo json_encode(["status" => "error", "message" => $conn->error]);
	}
} else {
	echo json_encode(["status" => "error", "message" => "ไม่พบข้อมูลลูกค้าห้องนี้"]);
}
$conn->close();
?>
