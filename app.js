async function fdFetch(url, options = {}) {
    const target = url.startsWith('http') ? url : `${window.FLEETDESK_BASE}/${url.replace(/^\/+/, '')}`;
    const response = await fetch(target, {
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        ...options,
    });
    const data = await response.json().catch(() => ({ success: false, error: 'Invalid server response' }));
    if (!response.ok || data.success === false) {
        throw new Error(data.error || 'Request failed');
    }
    return data.data ?? data;
}

function showToast(message) {
    const toast = document.getElementById('toast');
    if (!toast) return;
    toast.textContent = message;
    toast.hidden = false;
    clearTimeout(window.__toastTimer);
    window.__toastTimer = setTimeout(() => { toast.hidden = true; }, 2800);
}

function normalizeFormValue(input) {
    if (!input) return '';
    if (input.type === 'datetime-local' && input.value) {
        return input.value.replace('T', ' ') + ':00';
    }
    return input.value;
}

function normalizeStoredValue(value) {
    if (value === null || value === undefined) return '';
    return String(value);
}

function normalizeImageUrl(url) {
    if (!url) return '';
    const raw = String(url);
    const marker = '/assets/uploads/';
    const base = (window.FLEETDESK_BASE || '').replace(/\/+$/, '');
    const markerIndex = raw.indexOf(marker);
    if (markerIndex >= 0 && base) {
        return base + raw.slice(markerIndex);
    }
    if (raw.startsWith('assets/uploads/') && base) {
        return base + '/' + raw;
    }
    return raw;
}

document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('recordModal');
    const detailModal = document.getElementById('detailModal');
    let activeRecord = null;
    let activeRecordImageChanged = false;
    // Tracks in-flight image upload promises (keyed by the hidden field's id)
    // so form submission can wait for them instead of racing ahead and
    // submitting before the photo URL has been written into the form.
    const pendingImageUploads = new Map();

    document.querySelectorAll('[data-open-modal]').forEach((button) => {
        button.addEventListener('click', () => modal?.classList.add('open'));
    });
    document.querySelectorAll('[data-close-modal]').forEach((button) => {
        button.addEventListener('click', () => modal?.classList.remove('open'));
    });
    modal?.addEventListener('click', (event) => {
        if (event.target === modal) modal.classList.remove('open');
    });
    document.querySelectorAll('[data-close-detail]').forEach((button) => {
        button.addEventListener('click', () => detailModal?.classList.remove('open'));
    });
    detailModal?.addEventListener('click', (event) => {
        if (event.target === detailModal) detailModal.classList.remove('open');
    });

    const search = document.getElementById('tableSearch');
    search?.addEventListener('input', () => {
        const query = search.value.toLowerCase();
        document.querySelectorAll('table tbody tr').forEach((row) => {
            row.hidden = query !== '' && !row.textContent.toLowerCase().includes(query);
        });
    });

    document.querySelectorAll('[data-search-select]').forEach((input) => {
        const selectName = input.dataset.searchSelect;
        const form = input.closest('form');
        const select = form?.querySelector(`select[name="${selectName}"]`);
        const statusNote = form?.querySelector(`[data-status-for="${selectName}"]`);
        if (!select) return;

        function refreshStatus() {
            const option = select.selectedOptions[0];
            const status = option?.dataset.status || '';
            if (!statusNote) return;
            statusNote.textContent = status ? `Status: ${status.replaceAll('_', ' ')}` : 'Select a vehicle to see status.';
            statusNote.className = `vehicle-status-note ${status}`;
        }

        input.addEventListener('input', () => {
            const query = input.value.trim().toLowerCase();
            Array.from(select.options).forEach((option) => {
                if (!option.value) {
                    option.hidden = false;
                    return;
                }
                const haystack = option.dataset.search || option.textContent.toLowerCase();
                option.hidden = query !== '' && !haystack.includes(query);
            });
        });

        select.addEventListener('change', refreshStatus);
        refreshStatus();
    });

    document.querySelectorAll('[data-module-form]').forEach((form) => {
        form.addEventListener('submit', async (event) => {
            event.preventDefault();
            const submitBtn = form.querySelector('button[type="submit"]');
            const entity = form.dataset.entity || 'Record';

            // If a photo was just picked, its upload may still be in flight —
            // wait for it so the hidden URL field is populated before we read
            // the form, otherwise the record would save with no photo even
            // though the file itself finishes uploading a moment later.
            const ownUploads = Array.from(form.querySelectorAll('[data-image-field]'))
                .map((input) => pendingImageUploads.get(`field_${input.dataset.imageField}_url`))
                .filter(Boolean);
            if (ownUploads.length) {
                if (submitBtn) { submitBtn.disabled = true; submitBtn.dataset.originalText = submitBtn.textContent; submitBtn.textContent = 'Uploading photo…'; }
                await Promise.all(ownUploads);
            }

            const payload = {};
            new FormData(form).forEach((value, key) => {
                const input = form.elements[key];
                const normalized = normalizeFormValue(input);
                if (normalized !== '') {
                    payload[key] = normalized;
                }
            });
            form.querySelectorAll('[data-checklist]').forEach((list) => {
                const key = list.dataset.checklist;
                const selected = Array.from(list.querySelectorAll('input:checked')).map((input) => input.value);
                if (selected.length) {
                    payload[key] = selected.join(', ');
                }
            });

            if (submitBtn) { submitBtn.disabled = true; submitBtn.textContent = 'Saving…'; }
            try {
                await fdFetch(form.dataset.endpoint, { method: 'POST', body: JSON.stringify(payload) });
                showToast(`${entity} saved successfully`);
                window.location.reload();
            } catch (error) {
                showToast(error.message || 'Save failed');
                if (submitBtn) { submitBtn.disabled = false; submitBtn.textContent = submitBtn.dataset.originalText || 'Save'; }
            }
        });
    });

    // Badge styling helper — reuses existing .badge classes where they make sense
    function badgeHtml(label, value) {
        if (value === null || value === undefined || value === '') return '';
        const raw = String(value).toLowerCase();
        let cls = '';
        if (['1', 'true', 'yes'].includes(raw)) cls = 'active';
        else if (['0', 'false', 'no'].includes(raw)) cls = '';
        else cls = raw.replaceAll(' ', '_');
        const text = ['1', 'true', 'yes'].includes(raw) ? 'Active'
            : ['0', 'false', 'no'].includes(raw) ? 'Inactive'
            : String(value).replaceAll('_', ' ');
        return `<span class="badge ${cls}">${label ? label + ': ' : ''}${text}</span>`;
    }

    // Fields that are either shown elsewhere (header/title/badges/image) or
    // are raw foreign-key ids whose human-readable form is already shown via
    // a joined column (fleet_number, driver_name, mechanic_name, etc).
    const DETAIL_SKIP_FIELDS = new Set([
        'id', 'fleet_number', 'make', 'model', 'registration', 'department',
        'status', 'role', 'is_active', 'full_name', 'driver_name',
        'vehicle_photo', 'driver_photo', 'vehicle_id', 'driver_id', 'mechanic_id',
    ]);

    function renderFieldGrid(container, record, keys) {
        if (!container) return;
        container.innerHTML = keys.map((key) => `
            <div class="detail-item">
                <span>${key.replaceAll('_', ' ')}</span>
                <strong>${record[key] ?? '—'}</strong>
            </div>
        `).join('');
    }

    function renderRecordImage(record, imageField) {
        const link = document.getElementById('recordDetailImgLink');
        const img = document.getElementById('recordDetailImg');
        const placeholder = document.getElementById('recordImgPlaceholder');
        if (!img || !placeholder || !imageField) return;
        const url = normalizeImageUrl(record[imageField]);
        if (url) {
            // Bind onerror BEFORE setting src so a fast/cached failure is
            // still caught, then fall back to the placeholder instead of
            // leaving a broken-image icon on screen.
            img.onerror = () => {
                if (link) link.style.display = 'none';
                placeholder.style.display = 'flex';
            };
            img.src = url;
            if (link) { link.href = url; link.style.display = 'block'; }
            placeholder.style.display = 'none';
        } else {
            if (link) link.style.display = 'none';
            placeholder.style.display = 'flex';
        }
    }

    function renderDisplayImages(record) {
        const displayImagesEl = document.getElementById('recordDisplayImages');
        if (!displayImagesEl) return;
        let imageDefs = [];
        try { imageDefs = JSON.parse(displayImagesEl.dataset.images || '[]'); } catch { imageDefs = []; }
        displayImagesEl.innerHTML = imageDefs.map(def => {
            const url = normalizeImageUrl(record[def.field]);
            const label = def.label || def.field;
            return `
                <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">
                    ${url
                        ? `<a href="${url}" target="_blank" rel="noopener"><img src="${url}" alt="${label}" style="width:60px;height:60px;object-fit:cover;border-radius:10px;border:1px solid var(--line);" onerror="this.parentElement.style.display='none';this.closest('div').querySelector('.no-photo-fallback').style.display='flex';"></a>
                           <div class="no-photo-fallback" style="display:none;width:60px;height:60px;border-radius:10px;border:2px dashed var(--line);align-items:center;justify-content:center;color:var(--muted);font-size:9px;">No photo</div>`
                        : `<div style="width:60px;height:60px;border-radius:10px;border:2px dashed var(--line);display:flex;align-items:center;justify-content:center;color:var(--muted);font-size:9px;">No photo</div>`
                    }
                    <span style="font-size:10px;color:var(--muted);">${label}</span>
                </div>`;
        }).join('');
    }

    const detailMoreToggle = document.getElementById('detailMoreToggle');
    const detailMoreContent = document.querySelector('[data-detail-more-content]');
    detailMoreToggle?.addEventListener('click', function() {
        if (!detailMoreContent) return;
        const showing = detailMoreContent.style.display !== 'none';
        detailMoreContent.style.display = showing ? 'none' : '';
        this.textContent = showing ? `View more details (${this.dataset.count || ''})` : 'Show less details';
    });

    document.querySelectorAll('[data-view-record]').forEach((button) => {
        button.addEventListener('click', async () => {
            const row = button.closest('tr');
            activeRecord = JSON.parse(row.dataset.record || '{}');
            activeRecordImageChanged = false;
            const content = document.querySelector('[data-detail-content]');
            const imageField = detailModal?.dataset.imageField || '';
            const primaryKeys = Object.keys(activeRecord);

            renderFieldGrid(content, activeRecord, primaryKeys.filter((k) => !DETAIL_SKIP_FIELDS.has(k) && k !== imageField));

            // Profile title (header bar + profile row use the same logic)
            const profileTitle = activeRecord.fleet_number
                ? activeRecord.fleet_number
                    + (activeRecord.make ? ' — ' + activeRecord.make + ' ' + (activeRecord.model || '') : '')
                    + (activeRecord.driver_name ? ' · ' + activeRecord.driver_name : '')
                : (activeRecord.full_name || activeRecord.driver_name || Object.values(activeRecord)[1] || 'Details');
            const titleEl = document.getElementById('detailModalTitle');
            if (titleEl) titleEl.textContent = profileTitle;
            const profileTitleEl = document.getElementById('recordProfileTitle');
            if (profileTitleEl) profileTitleEl.textContent = profileTitle;

            // Profile badges — show whichever of these the record happens to carry
            const badgesEl = document.getElementById('recordProfileBadges');
            if (badgesEl) {
                badgesEl.innerHTML = [
                    activeRecord.registration ? `<span class="badge">${activeRecord.registration}</span>` : '',
                    activeRecord.department ? `<span class="badge">${activeRecord.department}</span>` : '',
                    badgeHtml('', activeRecord.status),
                    badgeHtml('', activeRecord.role),
                    'is_active' in activeRecord ? badgeHtml('', activeRecord.is_active) : '',
                ].join('');
            }

            renderRecordImage(activeRecord, imageField);
            renderDisplayImages(activeRecord);

            // Reset "view more" section and edit pane
            if (detailMoreToggle) detailMoreToggle.style.display = 'none';
            if (detailMoreContent) { detailMoreContent.style.display = 'none'; detailMoreContent.innerHTML = ''; }
            const viewPane  = document.getElementById('detailViewPane');
            const editPane  = document.getElementById('detailEditPane');
            const toggleBtn = document.getElementById('toggleEditBtn');
            if (viewPane) viewPane.style.display = '';
            if (editPane) editPane.style.display = 'none';
            if (toggleBtn) toggleBtn.textContent = 'Edit';

            detailModal?.classList.add('open');

            // The table row only carries the limited set of columns used by
            // the list view. Load the FULL record before allowing Edit, so
            // Save Changes can never silently blank out fields (like year,
            // colour, chassis number, etc.) that simply weren't part of
            // that narrower list query.
            const getEndpoint = detailModal?.dataset.getEndpoint;
            if (toggleBtn) toggleBtn.disabled = true;
            if (getEndpoint && activeRecord.id) {
                try {
                    const sep = getEndpoint.includes('?') ? '&' : '?';
                    const full = await fdFetch(`${getEndpoint}${sep}id=${activeRecord.id}`);
                    activeRecord = { ...activeRecord, ...full };

                    const moreKeys = Object.keys(full).filter((k) => !primaryKeys.includes(k) && !DETAIL_SKIP_FIELDS.has(k) && k !== imageField);
                    if (moreKeys.length && detailMoreToggle && detailMoreContent) {
                        renderFieldGrid(detailMoreContent, activeRecord, moreKeys);
                        detailMoreToggle.dataset.count = moreKeys.length;
                        detailMoreToggle.textContent = `View more details (${moreKeys.length})`;
                        detailMoreToggle.style.display = '';
                    }
                    // Refresh the photo in case the full record has a newer
                    // URL than the (possibly stale) table row carried.
                    renderRecordImage(activeRecord, imageField);
                } catch (err) {
                    console.error('Could not load full record', err);
                }
            }
            if (toggleBtn) toggleBtn.disabled = false;
        });
    });

    // ── Edit mode ──────────────────────────────────────────
    const toggleEditBtn = document.getElementById('toggleEditBtn');
    const cancelEditBtn = document.getElementById('cancelEditBtn');

    toggleEditBtn?.addEventListener('click', () => {
        const viewPane = document.getElementById('detailViewPane');
        const editPane = document.getElementById('detailEditPane');
        const editing  = editPane && editPane.style.display !== 'none';
        if (!editing) {
            // Fill edit form
            if (activeRecord) {
                Object.entries(activeRecord).forEach(([key, val]) => {
                    const el = document.getElementById('edit_' + key);
                    if (el) el.value = val ?? '';
                });
            }
            // Pre-check checklist fields (e.g. driver licence types) from
            // their comma-joined saved value.
            document.querySelectorAll('#detailEditForm [data-checklist]').forEach((list) => {
                const key = list.dataset.checklist;
                const selectedValues = String(activeRecord?.[key] || '').split(',').map((s) => s.trim()).filter(Boolean);
                list.querySelectorAll('input[type="checkbox"]').forEach((cb) => {
                    cb.checked = selectedValues.includes(cb.value);
                });
            });
            // Show current image in edit pane
            const imageField = detailModal?.dataset.imageField || '';
            const editImg = document.getElementById('editRecordImg');
            const editPlaceholder = document.getElementById('editImgPlaceholder');
            if (editImg && editPlaceholder && imageField) {
                const imageUrl = normalizeImageUrl(activeRecord?.[imageField]);
                if (imageUrl) {
                    editImg.src = imageUrl;
                    editImg.onerror = () => { editImg.style.display = 'none'; editPlaceholder.style.display = 'grid'; };
                    editImg.style.display = 'block';
                    editPlaceholder.style.display = 'none';
                } else {
                    editImg.style.display = 'none';
                    editPlaceholder.style.display = 'grid';
                }
            }
            if (viewPane) viewPane.style.display = 'none';
            if (editPane) editPane.style.display = '';
            toggleEditBtn.textContent = 'View';
        } else {
            if (viewPane) viewPane.style.display = '';
            if (editPane) editPane.style.display = 'none';
            toggleEditBtn.textContent = 'Edit';
        }
    });

    cancelEditBtn?.addEventListener('click', () => {
        const viewPane = document.getElementById('detailViewPane');
        const editPane = document.getElementById('detailEditPane');
        if (viewPane) viewPane.style.display = '';
        if (editPane) editPane.style.display = 'none';
        if (toggleEditBtn) toggleEditBtn.textContent = 'Edit';
    });

    // ── Image upload in edit mode ──────────────────────────
    document.getElementById('imgUploadInput')?.addEventListener('change', function() {
        if (!this.files[0] || !activeRecord?.id) return;
        const imageField = detailModal?.dataset.imageField || '';
        const uploadType = detailModal?.dataset.uploadType || 'misc';
        const status = document.getElementById('imgUploadStatus');
        status.textContent = 'Uploading…';
        const fd = new FormData();
        fd.append('image', this.files[0]);
        const uploadPromise = fetch(`api/upload.php?type=${uploadType}&id=${activeRecord.id}`, { method: 'POST', body: fd })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    if (imageField) activeRecord[imageField] = data.url;
                    activeRecordImageChanged = true;
                    const uploadedUrl = normalizeImageUrl(data.url);
                    const editImg = document.getElementById('editRecordImg');
                    const editPh  = document.getElementById('editImgPlaceholder');
                    if (editImg) { editImg.src = uploadedUrl; editImg.style.display = 'block'; }
                    if (editPh)  editPh.style.display = 'none';
                    status.textContent = '✓ Uploaded';
                    renderRecordImage(activeRecord, imageField);
                } else {
                    status.textContent = data.error || 'Upload failed';
                }
            })
            .catch(e => { status.textContent = 'Error: ' + e.message; })
            .finally(() => { pendingImageUploads.delete('editRecordImg'); });
        pendingImageUploads.set('editRecordImg', uploadPromise);
    });

    // ── Image preview/upload in add form (any entity with an image field) ──
    document.querySelectorAll('[data-image-field]').forEach((fileInput) => {
        fileInput.addEventListener('change', function() {
            const fieldName = this.dataset.imageField;
            const uploadType = this.dataset.uploadType || 'misc';
            const preview   = document.getElementById(`field_${fieldName}_preview`);
            const hiddenUrl = document.getElementById(`field_${fieldName}_url`);
            const status    = document.getElementById(`field_${fieldName}_status`);
            if (!this.files[0]) return;
            const reader = new FileReader();
            reader.onload = e => {
                if (preview) { preview.src = e.target.result; preview.style.display = 'block'; }
            };
            reader.readAsDataURL(this.files[0]);
            if (status) status.textContent = 'Uploading…';

            const fd = new FormData();
            fd.append('image', this.files[0]);
            const uploadPromise = fetch(`api/upload.php?type=${uploadType}&id=0`, { method: 'POST', body: fd })
                .then(res => res.json())
                .then(data => {
                    if (data.success && hiddenUrl) {
                        hiddenUrl.value = data.url;
                        if (status) status.textContent = '✓ Uploaded';
                    } else if (status) {
                        status.textContent = data.error || 'Upload failed';
                    }
                })
                .catch(e => {
                    console.error('Image upload failed', e);
                    if (status) status.textContent = 'Upload failed';
                })
                .finally(() => {
                    if (hiddenUrl) pendingImageUploads.delete(hiddenUrl.id);
                });
            if (hiddenUrl) pendingImageUploads.set(hiddenUrl.id, uploadPromise);
        });
    });

    // ── Edit form submit ───────────────────────────────────
    document.getElementById('detailEditForm')?.addEventListener('submit', async function(e) {
        e.preventDefault();
        if (!activeRecord?.id) return;
        const endpoint = detailModal?.dataset.editEndpoint;
        if (!endpoint) return;
        const entity = detailModal?.dataset.entity || 'Record';
        const btn = document.getElementById('saveEditBtn');
        btn.disabled = true; btn.textContent = 'Saving…';

        // Defensive: if a photo is still mid-upload, wait for it rather
        // than racing ahead (the edit-mode upload already writes straight
        // to the DB, but this keeps activeRecord/UI consistent either way).
        const pendingEditUpload = pendingImageUploads.get('editRecordImg');
        if (pendingEditUpload) await pendingEditUpload;

        const payload = {};
        new FormData(this).forEach((v, k) => {
            const nextValue = normalizeFormValue(this.elements[k]);
            const previousValue = normalizeStoredValue(activeRecord[k]);
            if (normalizeStoredValue(nextValue) !== previousValue) {
                payload[k] = nextValue === '' ? null : nextValue;
            }
        });
        this.querySelectorAll('[data-checklist]').forEach((list) => {
            const key = list.dataset.checklist;
            const selected = Array.from(list.querySelectorAll('input:checked')).map((input) => input.value);
            const nextValue = selected.join(', ');
            const previousValue = normalizeStoredValue(activeRecord[key]);
            if (nextValue !== previousValue) {
                payload[key] = nextValue === '' ? null : nextValue;
            }
        });
        if (!Object.keys(payload).length) {
            if (activeRecordImageChanged) {
                showToast(`${entity} updated successfully`);
                setTimeout(() => location.reload(), 600);
                return;
            }
            showToast('No changes to save');
            btn.disabled = false; btn.textContent = 'Save Changes';
            return;
        }
        try {
            const sep = endpoint.includes('?') ? '&' : '?';
            await fdFetch(`${endpoint}${sep}id=${activeRecord.id}`, {
                method: 'POST', body: JSON.stringify(payload)
            });
            showToast(`${entity} updated successfully`);
            setTimeout(() => location.reload(), 600);
        } catch(err) {
            showToast(err.message || 'Save failed');
            btn.disabled = false; btn.textContent = 'Save Changes';
        }
    });

    document.querySelectorAll('[data-delete-record]').forEach((button) => {
        button.addEventListener('click', async () => {
            const entity = detailModal?.dataset.entity || 'Record';
            if (!activeRecord || !activeRecord.id) {
                showToast(`No ${entity.toLowerCase()} selected`);
                return;
            }
            if (!confirm(`Delete this ${entity.toLowerCase()}? This cannot be undone.`)) {
                return;
            }
            try {
                await fdFetch(button.dataset.deleteEndpoint, {
                    method: 'POST',
                    body: JSON.stringify({ id: activeRecord.id })
                });
                showToast(`${entity} deleted`);
                window.location.reload();
            } catch (error) {
                showToast(error.message || 'Delete failed');
            }
        });
    });

    document.querySelectorAll('[data-dispose-record]').forEach((button) => {
        button.addEventListener('click', async () => {
            if (!activeRecord || !activeRecord.id) {
                showToast('No vehicle selected');
                return;
            }
            const reason = prompt('Reason for disposing this asset?', 'Asset disposed');
            if (reason === null) {
                return;
            }
            if (!confirm('Dispose this vehicle and close active driver allocations?')) {
                return;
            }
            try {
                await fdFetch(button.dataset.actionEndpoint, {
                    method: 'POST',
                    body: JSON.stringify({ id: activeRecord.id, reason })
                });
                showToast('Asset disposed');
                window.location.reload();
            } catch (error) {
                showToast(error.message || 'Dispose failed');
            }
        });
    });

    const gateForm = document.querySelector('[data-gate-mileage-form]');
    gateForm?.addEventListener('submit', async (event) => {
        event.preventDefault();
        const payload = {};
        new FormData(gateForm).forEach((value, key) => { if (value !== '') payload[key] = value; });
        try {
            await fdFetch('api/odometer.php?action=create', { method: 'POST', body: JSON.stringify(payload) });
            gateForm.reset();
            showToast('Mileage saved');
        } catch (error) {
            showToast(error.message || 'Mileage save failed');
        }
    });

    const fuelForm = document.querySelector('[data-module-form][data-endpoint*="api/fuel.php"]');
    if (fuelForm) {
        const fuelType = fuelForm.elements.fuel_type;
        const litres = fuelForm.elements.litres_filled;
        const price = fuelForm.elements.cost_per_litre;
        const total = fuelForm.elements.total_cost;
        let fuelPrices = {};

        fdFetch('api/fuel-prices.php').then((data) => {
            fuelPrices = data.prices || {};
            applyFuelPrice();
        }).catch(() => {});

        function applyFuelPrice() {
            if (fuelType && price && fuelPrices[fuelType.value]) {
                price.value = fuelPrices[fuelType.value];
            }
            calculateFuelTotal();
        }

        function calculateFuelTotal() {
            const litresValue = parseFloat(litres?.value || '0');
            const priceValue = parseFloat(price?.value || '0');
            if (total && litresValue > 0 && priceValue > 0) {
                total.value = (litresValue * priceValue).toFixed(2);
            }
        }

        fuelType?.addEventListener('change', applyFuelPrice);
        litres?.addEventListener('input', calculateFuelTotal);
        price?.addEventListener('input', calculateFuelTotal);
    }
});
