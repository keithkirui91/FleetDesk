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
    $completenessFields = $config['completeness_fields'] ?? [];
    ?>
    <div class="toolbar">
        <div>
            <h2 class="section-title"><?= e($config['title']) ?></h2>
            <div class="subtle"><?= e($config['description']) ?></div>
        </div>
        <div class="toolbar-left">
            <input class="input" id="tableSearch" placeholder="Search <?= e(strtolower($config['title'])) ?>">
            <?php foreach (($config['toolbar_links'] ?? []) as $link): ?>
                <a class="btn <?= e($link['class'] ?? '') ?>" href="<?= e(BASE_URL . '/' . ltrim($link['href'], '/')) ?>"><?= !empty($link['icon']) ? fd_icon($link['icon']) : '' ?> <?= e($link['label']) ?></a>
            <?php endforeach; ?>
            <?php if (empty($config['hide_add'])): ?>
                <button class="btn btn-primary" data-open-modal><?= fd_icon('plus') ?> Add <?= e($config['singular']) ?></button>
            <?php endif; ?>
        </div>
    </div>

    <?php if ($loadError): ?>
        <div class="alert alert-danger"><?= e($loadError) ?></div>
    <?php endif; ?>

    <div class="table-wrap">
        <table id="dataTable">
            <thead>
                <tr>
                    <?php if ($completenessFields): ?>
                        <th class="status-dot-head"></th>
                    <?php endif; ?>
                    <?php foreach ($config['columns'] as $column): ?>
                        <th><?= e($column['label']) ?></th>
                    <?php endforeach; ?>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <?php if (!$rows): ?>
                    <tr><td class="empty" colspan="<?= count($config['columns']) + 1 + ($completenessFields ? 1 : 0) ?>">No records yet.</td></tr>
                <?php endif; ?>
                <?php foreach ($rows as $row): ?>
                    <?php
                    $missingFields = [];
                    foreach ($completenessFields as $fieldName) {
                        $fieldValue = $row[$fieldName] ?? null;
                        if ($fieldValue === null || trim((string)$fieldValue) === '') {
                            $missingFields[] = str_replace('_', ' ', $fieldName);
                        }
                    }
                    $isComplete = count($missingFields) === 0;
                    ?>
                    <tr data-record='<?= e(json_encode($row, JSON_UNESCAPED_SLASHES)) ?>'>
                        <?php if ($completenessFields): ?>
                            <td class="status-dot-cell">
                                <span class="completion-dot <?= $isComplete ? 'complete' : 'incomplete' ?>" title="<?= $isComplete ? 'Complete record' : e('Missing: ' . implode(', ', $missingFields)) ?>"></span>
                            </td>
                        <?php endif; ?>
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

    <?php if (empty($config['hide_add'])): ?>
        <div class="modal-backdrop" id="recordModal">
            <div class="modal">
                <header>
                    <h2>Add <?= e($config['singular']) ?></h2>
                    <button class="btn btn-small" type="button" data-close-modal>Close</button>
                </header>
                <form data-module-form data-endpoint="<?= e($config['endpoint']) ?>" data-entity="<?= e($config['singular']) ?>">
                    <div class="form-grid">
                        <?php foreach ($config['fields'] as $field):
                            if (!empty($field['hide_on_add'])) continue; ?>
                        <div class="form-row <?= in_array(($field['type'] ?? 'text'), ['textarea', 'image', 'checklist'], true) ? 'full' : '' ?>">
                            <label for="<?= e($field['name']) ?>"><?= e($field['label']) ?></label>
                            <?php if (($field['type'] ?? 'text') === 'select'): ?>
                                <?php if (!empty($field['lookup'])): ?>
                                    <input class="input vehicle-select-search" type="text" placeholder="Type fleet no, registration, make or model" data-search-select="<?= e($field['name']) ?>">
                                    <div class="vehicle-status-note" data-status-for="<?= e($field['name']) ?>">Select a vehicle to see status.</div>
                                <?php endif; ?>
                                <select class="select" id="<?= e($field['name']) ?>" name="<?= e($field['name']) ?>" <?= !empty($field['required']) ? 'required' : '' ?>>
                                    <option value="">Select...</option>
                                    <?php foreach (($field['options'] ?? []) as $value => $option): ?>
                                        <?php
                                        $label = is_array($option) ? ($option['label'] ?? '') : $option;
                                        $status = is_array($option) ? ($option['status'] ?? '') : '';
                                        $search = is_array($option) ? ($option['search'] ?? $label) : $label;
                                        ?>
                                        <option value="<?= e($value) ?>" data-status="<?= e($status) ?>" data-search="<?= e(strtolower($search)) ?>"><?= e($label) ?></option>
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
                            <?php elseif (($field['type'] ?? 'text') === 'image'): ?>
                                <div style="display:flex;align-items:center;gap:12px;">
                                    <img id="field_<?= e($field['name']) ?>_preview" src="" alt=""
                                         style="width:64px;height:48px;object-fit:cover;border-radius:6px;border:1px solid var(--line);display:none;">
                                    <label class="btn btn-small" style="cursor:pointer;">
                                        <?= fd_icon('plus') ?> Upload Photo
                                        <input type="file" id="field_<?= e($field['name']) ?>" accept="image/*" capture="environment"
                                               data-image-field="<?= e($field['name']) ?>" data-upload-type="<?= e($config['upload_type'] ?? 'misc') ?>"
                                               style="display:none;">
                                    </label>
                                    <span id="field_<?= e($field['name']) ?>_status" style="font-size:11px;color:var(--muted);"></span>
                                </div>
                                <input type="hidden" id="field_<?= e($field['name']) ?>_url" name="<?= e($field['name']) ?>">
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
    <?php endif; ?>

    <?php
    $imageField   = $config['image_field'] ?? null;
    $uploadType   = $config['upload_type'] ?? 'misc';
    $editEndpoint = $config['edit_endpoint'] ?? null;
    $canEdit      = !empty($editEndpoint) || !empty($config['allow_edit']);
    // Derive the "get single record" endpoint from the create endpoint so the
    // view modal can always load the FULL row (not just the limited columns
    // used for the table/list), which both powers "View more" and prevents
    // Save from blanking out fields that aren't part of the list query.
    $getEndpoint  = !empty($config['endpoint']) ? str_replace('action=create', 'action=get', $config['endpoint']) : '';
    ?>
    <div class="modal-backdrop" id="detailModal"
         data-image-field="<?= e($imageField ?? '') ?>"
         data-upload-type="<?= e($uploadType) ?>"
         data-edit-endpoint="<?= e($editEndpoint ?? '') ?>"
         data-get-endpoint="<?= e($getEndpoint) ?>"
         data-entity="<?= e($config['singular']) ?>">
        <div class="modal" style="width:min(900px,96vw);">
            <header>
                <h2 id="detailModalTitle"><?= e($config['singular']) ?> Details</h2>
                <div style="display:flex;gap:8px;">
                    <?php if ($canEdit): ?>
                    <button class="btn btn-small btn-primary" type="button" id="toggleEditBtn">Edit</button>
                    <?php endif; ?>
                    <button class="btn btn-small" type="button" data-close-detail>Close</button>
                </div>
            </header>

            <!-- View pane -->
            <div id="detailViewPane">
                <div id="recordProfileRow" style="display:flex;gap:16px;align-items:center;padding:16px;border-bottom:1px solid var(--line);">
                    <?php if ($imageField): ?>
                    <!-- Record image panel (editable — vehicle / mechanic / driver) -->
                    <div id="recordImagePane" style="flex-shrink:0;">
                        <a id="recordDetailImgLink" href="" target="_blank" rel="noopener" style="display:none;">
                            <img id="recordDetailImg" src="" alt="Photo"
                                 style="width:108px;height:108px;object-fit:cover;border-radius:14px;border:1px solid var(--line);display:block;">
                        </a>
                        <div id="recordImgPlaceholder"
                             style="width:108px;height:108px;border-radius:14px;border:2px dashed var(--line);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;color:var(--muted);font-size:10px;text-align:center;">
                            <?= fd_icon('plus') ?><span>No photo</span>
                        </div>
                    </div>
                    <?php elseif (!empty($config['display_images'])): ?>
                    <!-- Read-only photo chips (e.g. driver allocations: vehicle + driver) -->
                    <div id="recordDisplayImages" style="display:flex;gap:10px;flex-shrink:0;"
                         data-images='<?= e(json_encode($config['display_images'])) ?>'></div>
                    <?php endif; ?>
                    <div style="flex:1;min-width:0;">
                        <h3 id="recordProfileTitle" style="margin:0 0 6px;font-size:17px;font-weight:800;color:var(--ink);overflow-wrap:anywhere;"></h3>
                        <div id="recordProfileBadges" style="display:flex;gap:6px;flex-wrap:wrap;"></div>
                    </div>
                </div>
                <div class="detail-grid" data-detail-content></div>
                <div id="detailMoreWrap" style="border-top:1px solid var(--line);">
                    <button type="button" class="btn btn-small" id="detailMoreToggle" style="margin:12px 16px;display:none;">View more details</button>
                    <div class="detail-grid" data-detail-more-content style="display:none;padding:0 16px 16px;"></div>
                </div>
            </div>


            <!-- Edit pane -->
            <div id="detailEditPane" style="display:none;">
                <?php if ($imageField): ?>
                <!-- Image upload row -->
                <div id="editImageRow" style="display:flex;align-items:center;gap:14px;padding:12px 14px;border-bottom:1px solid var(--line);">
                    <img id="editRecordImg" src="" alt="" style="width:80px;height:60px;object-fit:cover;border-radius:6px;border:1px solid var(--line);display:none;">
                    <div id="editImgPlaceholder" style="width:80px;height:60px;border-radius:6px;border:2px dashed var(--line);display:grid;place-items:center;color:var(--muted);font-size:11px;">No image</div>
                    <div>
                        <label class="btn btn-small" style="cursor:pointer;margin-bottom:4px;">
                            <?= fd_icon('plus') ?> Upload / Take Photo
                            <input type="file" id="imgUploadInput" accept="image/*" capture="environment" style="display:none;">
                        </label>
                        <div id="imgUploadStatus" style="font-size:11px;color:var(--muted);"></div>
                    </div>
                </div>
                <?php endif; ?>
                <form id="detailEditForm" style="padding:13px;">
                    <div class="form-grid">
                        <?php foreach ($config['fields'] as $field):
                            if ($imageField && ($field['name'] ?? '') === $imageField) continue; // handled by upload row above ?>
                        <div class="form-row <?= in_array(($field['type'] ?? 'text'), ['textarea', 'checklist'], true) || ($field['full'] ?? false) ? 'full' : '' ?>">
                            <label for="edit_<?= e($field['name']) ?>"><?= e($field['label']) ?></label>
                            <?php if (($field['type'] ?? 'text') === 'select'): ?>
                                <select class="select" id="edit_<?= e($field['name']) ?>" name="<?= e($field['name']) ?>">
                                    <option value="">— Select —</option>
                                    <?php foreach (($field['options'] ?? []) as $v => $lbl): ?>
                                        <option value="<?= e($v) ?>"><?= e(is_array($lbl) ? ($lbl['label'] ?? '') : $lbl) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            <?php elseif (($field['type'] ?? 'text') === 'checklist'): ?>
                                <div class="check-list" data-checklist="<?= e($field['name']) ?>">
                                    <?php foreach (($field['options'] ?? []) as $v => $lbl): ?>
                                        <label><input type="checkbox" value="<?= e($v) ?>"> <?= e($lbl) ?></label>
                                    <?php endforeach; ?>
                                </div>
                            <?php elseif (($field['type'] ?? 'text') === 'textarea'): ?>
                                <textarea id="edit_<?= e($field['name']) ?>" name="<?= e($field['name']) ?>"></textarea>
                            <?php else: ?>
                                <input class="input" id="edit_<?= e($field['name']) ?>" name="<?= e($field['name']) ?>" type="<?= e($field['type'] ?? 'text') ?>">
                            <?php endif; ?>
                        </div>
                        <?php endforeach; ?>
                    </div>
                    <div style="display:flex;justify-content:flex-end;gap:8px;padding-top:10px;border-top:1px solid var(--line);">
                        <button class="btn" type="button" id="cancelEditBtn">Cancel</button>
                        <button class="btn btn-primary" type="submit" id="saveEditBtn">Save Changes</button>
                    </div>
                </form>
            </div>

            <footer>
                <?php foreach (($config['detail_actions'] ?? []) as $action): ?>
                    <button class="btn <?= e($action['class'] ?? '') ?>" type="button" <?= e($action['attribute'] ?? '') ?> data-action-endpoint="<?= e($action['endpoint'] ?? '') ?>"><?= !empty($action['icon']) ? fd_icon($action['icon']) : '' ?> <?= e($action['label']) ?></button>
                <?php endforeach; ?>
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

function active_vehicle_options(): array
{
    $rows = db_all("
        SELECT id, fleet_number, registration, make, model, status
        FROM vehicles
        WHERE status = 'active'
        ORDER BY fleet_number
    ");
    $options = [];
    foreach ($rows as $row) {
        $options[$row['id']] = [
            'label' => $row['fleet_number'] . ' - ' . $row['registration'] . ' (' . $row['make'] . ' ' . $row['model'] . ')',
            'status' => $row['status'],
            'search' => implode(' ', [$row['fleet_number'], $row['registration'], $row['make'], $row['model'], $row['status']]),
        ];
    }
    return $options;
}

function assignment_vehicle_options(): array
{
    $rows = db_all("
        SELECT id, fleet_number, registration, make, model, status
        FROM vehicles
        WHERE status <> 'decommissioned'
        ORDER BY fleet_number
    ");
    $options = [];
    foreach ($rows as $row) {
        $options[$row['id']] = [
            'label' => $row['fleet_number'] . ' - ' . $row['registration'] . ' (' . $row['make'] . ' ' . $row['model'] . ')',
            'status' => $row['status'],
            'search' => implode(' ', [$row['fleet_number'], $row['registration'], $row['make'], $row['model'], $row['status']]),
        ];
    }
    return $options;
}

function driver_options(): array
{
    $rows = db_all("SELECT id, CONCAT(full_name, ' - ', department) AS label FROM drivers WHERE is_active = 1 ORDER BY full_name");
    return array_column($rows, 'label', 'id');
}

function mechanic_options(): array
{
    $rows = db_all("SELECT id, full_name FROM mechanics WHERE is_active = 1 ORDER BY full_name");
    return array_column($rows, 'full_name', 'id');
}
