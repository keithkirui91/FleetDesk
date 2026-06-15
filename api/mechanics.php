<?php
require_once __DIR__ . '/common.php';

route_simple_module(
    'mechanics',
    ['employee_id', 'full_name', 'phone', 'email', 'specialisations', 'date_joined', 'is_active', 'notes'],
    "SELECT m.*, COUNT(jc.id) AS total_jobs, SUM(jc.status <> 'closed') AS open_jobs
     FROM mechanics m
     LEFT JOIN job_cards jc ON jc.mechanic_id = m.id
     GROUP BY m.id
     ORDER BY m.full_name"
);
