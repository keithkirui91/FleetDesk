<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/helpers.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

try {
    $adminCount = (int)db_value('SELECT COUNT(*) FROM users');
    if ($adminCount === 0) {
        redirect_to('auth.php');
    }
} catch (Throwable $e) {
    $adminCount = -1;
}

if (!empty($_SESSION['admin_id'])) {
    redirect_to('dashboard.php');
}

$error = '';
$timeout = isset($_GET['timeout']);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = (string)($_POST['password'] ?? '');

    if ($username !== '' && $password !== '') {
        if ($username === 'Data Entry' && $password === 'Data Entry') {
            $_SESSION['data_entry'] = true;
            $_SESSION['data_entry_username'] = 'Data Entry';
            $_SESSION['last_activity'] = time();
            redirect_to('gate-mileage.php');
        }

        try {
            $stmt = getDB()->prepare('SELECT id, username, password_hash FROM users WHERE username = ? LIMIT 1');
            $stmt->bind_param('s', $username);
            $stmt->execute();
            $user = $stmt->get_result()->fetch_assoc();

            if ($user && password_verify($password, $user['password_hash'])) {
                $_SESSION['admin_id'] = (int)$user['id'];
                $_SESSION['admin_username'] = $user['username'];
                $_SESSION['last_activity'] = time();
                redirect_to('dashboard.php');
            }
        } catch (Throwable $e) {
            $error = 'Database connection failed. Check config.php credentials.';
        }
        if ($error === '') {
            $error = 'Invalid username or password.';
        }
    } else {
        $error = 'Please enter your username and password.';
    }
}
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign in - FleetDesk</title>
    <link rel="stylesheet" href="<?= e(BASE_URL) ?>/main.css">
</head>
<body class="login-page">
    <main class="login-card">
        <h1>Kamok FleetDesk</h1>
        <p>Sign in to manage vehicles, jobs, services, fuel, mileage, and mechanics.</p>
        <?php if ($adminCount < 0): ?>
            <div class="alert alert-danger">Database is not ready. Import schema.sql and check config.php.</div>
        <?php endif; ?>
        <?php if ($timeout): ?><div class="alert">Session expired. Please sign in again.</div><?php endif; ?>
        <?php if ($error): ?><div class="alert alert-danger"><?= e($error) ?></div><?php endif; ?>
        <form method="post">
            <div class="form-row">
                <label for="username">Username</label>
                <input class="input" id="username" name="username" autocomplete="username" required autofocus>
            </div>
            <div class="form-row">
                <label for="password">Password</label>
                <input class="input" id="password" name="password" type="password" autocomplete="current-password" required>
            </div>
            <button class="btn btn-primary" type="submit">Sign in</button>
            <a class="btn" href="<?= e(BASE_URL) ?>/auth.php">Admin setup</a>
        </form>
    </main>
</body>
</html>
