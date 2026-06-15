<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Mechanics',
    'singular' => 'Mechanic',
    'description' => 'Workshop staff, contacts, specialisations, and active job load.',
    'endpoint' => 'api/mechanics.php?action=create',
    'delete_endpoint' => 'api/mechanics.php?action=delete',
    'sql' => "SELECT m.id, m.employee_id, m.full_name, m.phone, m.email, m.specialisations, m.is_active,
                     COUNT(jc.id) AS total_jobs,
                     SUM(jc.status <> 'closed') AS open_jobs
              FROM mechanics m
              LEFT JOIN job_cards jc ON jc.mechanic_id = m.id
              GROUP BY m.id
              ORDER BY m.full_name",
    'columns' => [
        ['key' => 'employee_id', 'label' => 'Employee ID'],
        ['key' => 'full_name', 'label' => 'Name'],
        ['key' => 'phone', 'label' => 'Phone'],
        ['key' => 'email', 'label' => 'Email'],
        ['key' => 'specialisations', 'label' => 'Specialisations'],
        ['key' => 'open_jobs', 'label' => 'Open Jobs'],
        ['key' => 'is_active', 'label' => 'Active'],
    ],
    'fields' => [
        ['name' => 'employee_id', 'label' => 'Employee ID', 'required' => true],
        ['name' => 'full_name', 'label' => 'Full name', 'required' => true],
        ['name' => 'phone', 'label' => 'Phone'],
        ['name' => 'email', 'label' => 'Email', 'type' => 'email'],
        ['name' => 'specialisations', 'label' => 'Specialisations'],
        ['name' => 'date_joined', 'label' => 'Date joined', 'type' => 'date'],
        ['name' => 'notes', 'label' => 'Notes', 'type' => 'textarea'],
    ],
]);
