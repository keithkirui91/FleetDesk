<?php
declare(strict_types=1);

require_once __DIR__ . '/auth_check.php';
require_once __DIR__ . '/db.php';

function render_module_page(array $config): void
{
    $page_title = $config['title'];
    $page_heading = $config['title'];
    $rows = [];
    $loadError = '';

    try {
        $rows = db_all($config['sql']);
    } catch (Throwable $e) {
        $loadError = $e->getMessage();
    }

    include __DIR__ . '/header.php';
    include __DIR__ . '/sidebar.php';
    ?>
    <div class="toolbar">
        <div>
            <h2 class="section-title"><?= e($config['title']) ?></h2>
            <div class="subtle"><?= e($config['description']) ?></div>
        </div>
        <div class="toolbar-left">
            <input class="input" id="tableSearch" placeholder="Search <?= e(strtolower($config['title'])) ?>">
            <button class="btn btn-primary" data-open-modal><?= fd_icon('plus') ?> Add <?= e($config['singular']) ?></button>
        </div>
    </div>

    <?php if ($loadError): ?>
        <div class="alert alert-danger"><?= e($loadError) ?></div>
    <?php endif; ?>

    <div class="table-wrap">
        <table id="dataTable">
            <thead>
                <tr>
                    <?php foreach ($config['columns'] as $column): ?>
                        <th><?= e($column['label']) ?></th>
                    <?php endforeach; ?>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <?php if (!$rows): ?>
                    <tr><td class="empty" colspan="<?= count($config['columns']) + 1 ?>">No records yet.</td></tr>
                <?php endif; ?>
                <?php foreach ($rows as $row): ?>
                    <tr data-record='<?= e(json_encode($row, JSON_UNESCAPED_SLASHES)) ?>'>
                        <?php foreach ($config['columns'] as $column): ?>
                            <?php $value = $row[$column['key']] ?? ''; ?>
                            <td>
                                <?php if (($column['badge'] ?? false) && $value !== ''): ?>
                                    <span class="badge <?= e((string)$value) ?>"><?= e(str_replace('_', ' ', (string)$value)) ?></span>
                                <?php else: ?>
                                    <?= e($value) ?>
                                <?php endif; ?>
                            </td>
                        <?php endforeach; ?>
                        <td class="actions"><button class="btn btn-small" type="button" data-view-record>View</button></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <div class="modal-backdrop" id="recordModal">
        <div class="modal">
            <header>
                <h2>Add <?= e($config['singular']) ?></h2>
                <button class="btn btn-small" type="button" data-close-modal>Close</button>
            </header>
            <form data-module-form data-endpoint="<?= e($config['endpoint']) ?>">
                <div class="form-grid">
                    <?php foreach ($config['fields'] as $field): ?>
                        <div class="form-row <?= ($field['type'] ?? 'text') === 'textarea' ? 'full' : '' ?>">
                            <label for="<?= e($field['name']) ?>"><?= e($field['label']) ?></label>
                            <?php if (($field['type'] ?? 'text') === 'select'): ?>
                                <select class="select" id="<?= e($field['name']) ?>" name="<?= e($field['name']) ?>" <?= !empty($field['required']) ? 'required' : '' ?>>
                                    <option value="">Select...</option>
                                    <?php foreach (($field['options'] ?? []) as $value => $label): ?>
                                        <option value="<?= e($value) ?>"><?= e($label) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            <?php elseif (($field['type'] ?? 'text') === 'checklist'): ?>
                                <div class="check-list" data-checklist="<?= e($field['name']) ?>">
                                    <?php foreach (($field['options'] ?? []) as $value => $label): ?>
                                        <label><input type="checkbox" value="<?= e($value) ?>"> <?= e($label) ?></label>
                                    <?php endforeach; ?>
                                </div>
                            <?php elseif (($field['type'] ?? 'text') === 'textarea'): ?>
                                <textarea id="<?= e($field['name']) ?>" name="<?= e($field['name']) ?>" <?= !empty($field['required']) ? 'required' : '' ?> <?= !empty($field['placeholder']) ? 'placeholder="' . e($field['placeholder']) . '"' : '' ?>></textarea>
                            <?php else: ?>
                                <input class="input" id="<?= e($field['name']) ?>" name="<?= e($field['name']) ?>" type="<?= e($field['type'] ?? 'text') ?>" <?= !empty($field['required']) ? 'required' : '' ?> <?= isset($field['value']) ? 'value="' . e($field['value']) . '"' : '' ?> <?= !empty($field['readonly']) ? 'readonly' : '' ?>>
                            <?php endif; ?>
                        </div>
                    <?php endforeach; ?>
                </div>
                <footer>
                    <button class="btn" type="button" data-close-modal>Cancel</button>
                    <button class="btn btn-primary" type="submit">Save <?= e($config['singular']) ?></button>
                </footer>
            </form>
        </div>
    </div>

    <div class="modal-backdrop" id="detailModal">
        <div class="modal">
            <header>
                <h2><?= e($config['singular']) ?> Details</h2>
                <button class="btn btn-small" type="button" data-close-detail>Close</button>
            </header>
            <div class="detail-grid" data-detail-content></div>
            <footer>
                <button class="btn btn-danger" type="button" data-delete-record data-delete-endpoint="<?= e($config['delete_endpoint'] ?? '') ?>">Delete <?= e($config['singular']) ?></button>
            </footer>
        </div>
    </div>
    <?php
    include __DIR__ . '/footer.php';
}

function vehicle_options(): array
{
    $rows = db_all("SELECT id, CONCAT(fleet_number, ' - ', registration) AS label FROM vehicles ORDER BY fleet_number");
    return array_column($rows, 'label', 'id');
}

function mechanic_options(): array
{
    $rows = db_all("SELECT id, full_name FROM mechanics WHERE is_active = 1 ORDER BY full_name");
    return array_column($rows, 'full_name', 'id');
}
