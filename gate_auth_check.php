<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (empty($_SESSION['data_entry'])) {
    redirect_to('index.php');
}

if (!empty($_SESSION['last_activity']) && time() - (int)$_SESSION['last_activity'] > SESSION_TIMEOUT) {
    session_unset();
    session_destroy();
    redirect_to('index.php?timeout=1');
}

$_SESSION['last_activity'] = time();
