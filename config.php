<?php
$host = 'db'; // แก้จาก 'localhost' เป็น 'db'
$dbname = 'equipment_borrow_db'; // แก้ให้ตรงกับ MYSQL_DATABASE ในไฟล์ Compose
$username = 'root'; 
$password = 'rootpassword'; // แก้ให้ตรงกับ MYSQL_ROOT_PASSWORD ที่คุณตั้งไว้

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}
?>