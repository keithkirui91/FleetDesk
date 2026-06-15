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

document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('recordModal');
    const detailModal = document.getElementById('detailModal');
    let activeRecord = null;

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

    document.querySelectorAll('[data-module-form]').forEach((form) => {
        form.addEventListener('submit', async (event) => {
            event.preventDefault();
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

            const submitBtn = form.querySelector('[type="submit"]');
            if (submitBtn) { submitBtn.disabled = true; submitBtn.textContent = 'Saving…'; }
            try {
                await fdFetch(form.dataset.endpoint, { method: 'POST', body: JSON.stringify(payload) });
                showToast('Saved successfully');
                window.location.reload();
            } catch (error) {
                showToast(error.message || 'Save failed');
            }
        });
    });

    document.querySelectorAll('[data-view-record]').forEach((button) => {
        button.addEventListener('click', () => {
            const row = button.closest('tr');
            activeRecord = JSON.parse(row.dataset.record || '{}');
            const content = document.querySelector('[data-detail-content]');
            if (!content) return;
            content.innerHTML = Object.entries(activeRecord)
                .filter(([key]) => key !== 'id')
                .map(([key, value]) => `
                    <div class="detail-item">
                        <span>${key.replaceAll('_', ' ')}</span>
                        <strong>${value ?? ''}</strong>
                    </div>
                `).join('');
            detailModal?.classList.add('open');
        });
    });

    document.querySelectorAll('[data-delete-record]').forEach((button) => {
        button.addEventListener('click', async () => {
            if (!activeRecord || !activeRecord.id) {
                showToast('No record selected');
                return;
            }
            if (!confirm('Delete this record? This cannot be undone.')) {
                return;
            }
            try {
                await fdFetch(button.dataset.deleteEndpoint, {
                    method: 'POST',
                    body: JSON.stringify({ id: activeRecord.id })
                });
                showToast('Deleted successfully');
                window.location.reload();
            } catch (error) {
                showToast(error.message || 'Delete failed');
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
