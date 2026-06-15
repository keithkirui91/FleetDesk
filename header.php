<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
$pageTitle = isset($page_title) ? $page_title . ' - ' . APP_NAME : APP_NAME;
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e($pageTitle) ?></title>
    <link rel="stylesheet" href="<?= e(BASE_URL) ?>/main.css">
    <link rel="stylesheet" href="<?= e(BASE_URL) ?>/components.css">
    <link rel="stylesheet" href="<?= e(BASE_URL) ?>/layout.css">
</head>
<body>
