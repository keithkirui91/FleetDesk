<?php
require_once __DIR__ . '/common.php';

// Only allow logged-in users
if (session_status() === PHP_SESSION_NONE) session_start();
if (empty($_SESSION['user_id']) && empty($_SESSION['admin_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorised']);
    exit;
}

$type = $_GET['type'] ?? 'vehicle';
$id   = (int)($_GET['id'] ?? 0);

// Whitelist upload types — doubles as the column/table map below, so $type
// is never used to build SQL directly. The 'folder' value is explicit
// (not derived by string concatenation) so storage layout is unambiguous:
// every vehicle photo lands in assets/uploads/vehicles/, every mechanic
// photo in assets/uploads/mechanics/, every driver photo in
// assets/uploads/drivers/.
$targetMap = [
    'vehicle'  => ['table' => 'vehicles',  'column' => 'primary_image_url', 'folder' => 'vehicles'],
    'mechanic' => ['table' => 'mechanics', 'column' => 'photo_url',         'folder' => 'mechanics'],
    'driver'   => ['table' => 'drivers',   'column' => 'photo_url',         'folder' => 'drivers'],
];
$target = $targetMap[$type] ?? ['table' => null, 'column' => null, 'folder' => 'misc'];
$folder = $target['folder'];

if (empty($_FILES['image'])) {
    echo json_encode(['error' => 'No file uploaded']);
    exit;
}

$file    = $_FILES['image'];
$allowed = ['image/jpeg','image/jpg','image/png','image/webp','image/gif'];

if (!in_array($file['type'], $allowed)) {
    echo json_encode(['error' => 'Only JPG, PNG, WEBP and GIF images are allowed']);
    exit;
}

if ($file['size'] > 5 * 1024 * 1024) {
    echo json_encode(['error' => 'Image must be under 5MB']);
    exit;
}

// Build upload path
$uploadDir = __DIR__ . '/../assets/uploads/' . $folder . '/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

$ext      = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION)) ?: 'jpg';
$filename = $type . '_' . $id . '_' . time() . '.' . $ext;
$dest     = $uploadDir . $filename;
$storedPath = 'assets/uploads/' . $folder . '/' . $filename;
$url      = rtrim(BASE_URL, '/') . '/' . $storedPath;

if (!move_uploaded_file($file['tmp_name'], $dest)) {
    echo json_encode(['error' => 'Failed to save file']);
    exit;
}

// Update the record's image column if we know which table/column to write to
if ($id && $target['table']) {
    $db   = getDB();
    $stmt = $db->prepare("UPDATE {$target['table']} SET {$target['column']} = ? WHERE id = ?");
    $stmt->bind_param('si', $url, $id);
    $stmt->execute();
}

echo json_encode(['success' => true, 'url' => $url, 'stored_path' => $storedPath, 'filename' => $filename]);
