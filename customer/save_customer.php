
<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "hotel_app");

$data = json_decode(file_get_contents("php://input"), true);

if(isset($data['name']) && isset($data['tel']) && isset($data['people']) && isset($data['room'])) {
    $name = $conn->real_escape_string($data['name']);
    $tel = $conn->real_escape_string($data['tel']);
    $people = $conn->real_escape_string($data['people']);
    $room = $conn->real_escape_string($data['room']);

    // ตรวจสอบว่าห้องนี้ถูกจองแล้วหรือยัง
    $checkSql = "SELECT * FROM customer_records WHERE room = '$room'";
    $result = $conn->query($checkSql);
    if ($result && $result->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "มีคนจองแล้ว"]);
    } else {
        $insertSql = "INSERT INTO customer_records (name, tel, people, room) VALUES ('$name', '$tel', '$people', '$room')";
        if ($conn->query($insertSql) === TRUE) {
            echo json_encode(["status" => "success", "message" => "Record saved"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
$conn->close();
?>