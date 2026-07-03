<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Mechanics',
    'singular' => 'Mechanic',
    'description' => 'Workshop staff, contacts, specialisations, and active job load.',
    'endpoint' => 'api/mechanics.php?action=create',
    'edit_endpoint' => 'api/mechanics.php?action=update',
    'delete_endpoint' => 'api/mechanics.php?action=delete',
    'image_field' => 'photo_url',
    'upload_type' => 'mechanic',
    'completeness_fields' => ['employee_id', 'full_name', 'department', 'phone', 'email', 'specialisations', 'date_joined'],
    'sql' => "SELECT m.id, m.employee_id, m.full_name, m.department, m.phone, m.email,
                     m.specialisations, m.is_active, m.photo_url,
                     COUNT(jc.id) AS total_jobs,
                     SUM(jc.status <> 'closed') AS open_jobs
              FROM mechanics m
              LEFT JOIN job_cards jc ON jc.mechanic_id = m.id
              GROUP BY m.id
              ORDER BY m.full_name",
    'columns' => [
        ['key' => 'employee_id', 'label' => 'Employee ID'],
        ['key' => 'full_name', 'label' => 'Name'],
        ['key' => 'department', 'label' => 'Department'],
        ['key' => 'phone', 'label' => 'Phone'],
        ['key' => 'email', 'label' => 'Email'],
        ['key' => 'specialisations', 'label' => 'Specialisations'],
        ['key' => 'open_jobs', 'label' => 'Open Jobs'],
        ['key' => 'is_active', 'label' => 'Active'],
    ],
    'fields' => [
        ['name' => 'employee_id', 'label' => 'Employee ID', 'required' => true],
        ['name' => 'full_name', 'label' => 'Full name', 'required' => true],
        ['name' => 'department', 'label' => 'Department'],
        ['name' => 'phone', 'label' => 'Phone'],
        ['name' => 'email', 'label' => 'Email', 'type' => 'email'],
        ['name' => 'specialisations', 'label' => 'Specialisations'],
        ['name' => 'date_joined', 'label' => 'Date joined', 'type' => 'date'],
        ['name' => 'is_active', 'label' => 'Status', 'type' => 'select',
            'options' => ['1' => 'Active', '0' => 'Inactive']],
        ['name' => 'photo_url', 'label' => 'Photo', 'type' => 'image'],
        ['name' => 'notes', 'label' => 'Notes', 'type' => 'textarea'],
    ],
]);
