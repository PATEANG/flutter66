
<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "hotel_app");


if (isset($_GET['detail'])) {
    $roomNum = intval($_GET['detail']);
    $sql = "SELECT * FROM customer_records WHERE room = '$roomNum' ORDER BY id DESC LIMIT 1";
    $result = $conn->query($sql);
    if ($result && $row = $result->fetch_assoc()) {
        echo json_encode(['customer' => $row]);
    } else {
        echo json_encode(['vacant' => true]);
    }
    $conn->close();
    exit;
}

$sql = "SELECT room FROM customer_records";
$result = $conn->query($sql);
$totalRooms = 10;
$rooms = array_fill(0, $totalRooms, false); // index 0 = Room 1
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $roomNum = intval($row['room']);
        if ($roomNum >= 1 && $roomNum <= $totalRooms) {
            $rooms[$roomNum - 1] = true;
        }
    }
    echo json_encode(["rooms" => $rooms]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
$conn->close();
?>
