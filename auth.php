<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/helpers.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (($_GET['action'] ?? '') === 'logout') {
    session_unset();
    session_destroy();
    redirect_to('index.php');
}

$error = '';
$created = false;

try {
    $adminCount = (int)db_value('SELECT COUNT(*) FROM users');
} catch (Throwable $e) {
    $adminCount = -1;
    $error = 'Database is not ready. Import schema.sql and check config.php credentials.';
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $adminCount === 0) {
    $username = trim($_POST['username'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = (string)($_POST['password'] ?? '');
    $confirm = (string)($_POST['confirm_password'] ?? '');

    if ($username === '' || $email === '' || $password === '') {
        $error = 'Username, email, and password are required.';
    } elseif ($password !== $confirm) {
        $error = 'Passwords do not match.';
    } elseif (strlen($password) < 8) {
        $error = 'Use at least 8 characters for the password.';
    } else {
        $hash = password_hash($password, PASSWORD_DEFAULT);
        $stmt = getDB()->prepare('INSERT INTO users (username, email, password_hash, role) VALUES (?, ?, ?, "admin")');
        $stmt->bind_param('sss', $username, $email, $hash);
        $stmt->execute();
        $created = true;
        $adminCount = 1;
    }
}
?>
<!doctype html>
<html lang="en">
<head>
    <meta name="google-site-verification" content="TyPxQjuEjnElCKSS-ABW195LVWh0cGYLsJqPi6hlxng" />
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Setup - FleetDesk</title>
    <link rel="stylesheet" href="<?= e(BASE_URL) ?>/main.css">
</head>
<body class="login-page">
    <main class="login-card">
        <h1>FleetDesk setup</h1>
        <?php if ($created): ?>
            <div class="alert alert-ok">Admin saved. You can now sign in.</div>
            <a class="btn btn-primary" href="<?= e(BASE_URL) ?>/index.php">Go to sign in</a>
        <?php elseif ($adminCount > 0): ?>
            <div class="alert alert-ok">Admin already set. Setup is locked to keep the garage account safe.</div>
            <a class="btn btn-primary" href="<?= e(BASE_URL) ?>/index.php">Go to sign in</a>
        <?php else: ?>
            <p>Create the first administrator for this FleetDesk installation.</p>
            <?php if ($error): ?><div class="alert alert-danger"><?= e($error) ?></div><?php endif; ?>
            <form method="post">
                <div class="form-row">
                    <label for="username">Username</label>
                    <input class="input" id="username" name="username" autocomplete="username" required>
                </div>
                <div class="form-row">
                    <label for="email">Email</label>
                    <input class="input" id="email" name="email" type="email" autocomplete="email" required>
                </div>
                <div class="form-row">
                    <label for="password">Password</label>
                    <input class="input" id="password" name="password" type="password" autocomplete="new-password" required>
                </div>
                <div class="form-row">
                    <label for="confirm_password">Confirm password</label>
                    <input class="input" id="confirm_password" name="confirm_password" type="password" autocomplete="new-password" required>
                </div>
                <button class="btn btn-primary" type="submit">Save admin</button>
            </form>
        <?php endif; ?>
    </main>
</body>
</html>
