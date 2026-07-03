<?php
$nav_items = [
    ['dashboard.php',         'grid',      'Dashboard'],
    ['fleet.php',             'truck',     'Fleet'],
    ['drivers.php',           'users',     'Drivers'],
    ['driver-allocations.php','users',     'Driver Allocations'],
    ['jobs.php',              'tool',      'Job Cards'],
    ['services.php',          'calendar',  'Service'],
    ['fuel.php',              'droplet',   'Fuel'],
    ['mechanics.php',         'users',     'Mechanics'],
    ['mileage.php',           'clock',     'Mileage'],
    ['reports.php',           'bar-chart', 'Reports'],
];
$active = current_page();
?>
<div class="app-shell">
    <aside class="sidebar">
        <a class="brand" href="<?= e(BASE_URL) ?>/dashboard.php">
            <span class="brand-mark"><?= fd_icon('truck') ?></span>
            <span><strong>Kamok FleetDesk</strong><small>Garage Manager</small></span>
        </a>
        <nav class="nav">
            <?php foreach ($nav_items as [$href, $icon, $label]): ?>
                <a class="<?= $active === basename($href, '.php') ? 'active' : '' ?>" href="<?= e(BASE_URL . '/' . $href) ?>">
                    <?= fd_icon($icon) ?><span><?= e($label) ?></span>
                </a>
            <?php endforeach; ?>
        </nav>
        <div class="sidebar-user">
            <div>
                <strong><?= e($_SESSION['admin_username'] ?? 'Admin') ?></strong>
                <small>Administrator</small>
            </div>
            <a title="Logout" href="<?= e(BASE_URL) ?>/auth.php?action=logout"><?= fd_icon('logout') ?></a>
        </div>
    </aside>
    <main class="main">
        <header class="topbar">
            <h1><?= e($page_heading ?? $page_title ?? 'FleetDesk') ?></h1>
            <span><?= e(date('D, d M Y')) ?></span>
        </header>
        <section class="content">
