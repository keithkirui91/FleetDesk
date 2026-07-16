'use client';

import { useEffect, useMemo, useState } from 'react';
import { Plus, X } from 'lucide-react';

function Badge({ value }) {
  if (value === null || value === undefined || value === '') return null;
  return <span className={`badge ${value}`}>{String(value).replace(/_/g, ' ')}</span>;
}

function normalizeImageUrl(value) {
  if (!value) return '';
  const raw = String(value);
  if (raw.startsWith('http') || raw.startsWith('/')) return raw;
  if (raw.startsWith('assets/uploads/')) return `/${raw.replace(/^assets\/uploads\//, 'uploads/')}`;
  return raw;
}

async function uploadImage(file, uploadType, id = 0) {
  const formData = new FormData();
  formData.append('image', file);
  const res = await fetch(`/api/upload?type=${uploadType || 'misc'}&id=${id || 0}`, { method: 'POST', body: formData });
  const json = await res.json();
  if (!json.success) throw new Error(json.error || 'Image upload failed.');
  return json.url;
}

function ImageInput({ field, value, onChange, uploadType, recordId }) {
  const [preview, setPreview] = useState(normalizeImageUrl(value));
  const [status, setStatus] = useState('');

  useEffect(() => {
    setPreview(normalizeImageUrl(value));
  }, [value]);

  async function handleFile(file) {
    if (!file) return;
    setPreview(URL.createObjectURL(file));
    setStatus('Uploading photo...');
    try {
      const url = await uploadImage(file, uploadType, recordId);
      onChange(url);
      setPreview(normalizeImageUrl(url));
      setStatus('Uploaded');
    } catch (e) {
      setStatus(e.message);
    }
  }

  return (
    <div className="image-input">
      <div className="image-preview">
        {preview ? <img src={preview} alt={field.label} /> : <span>No photo</span>}
      </div>
      <label className="btn btn-small">
        <Plus className="icon" /> Upload Photo
        <input type="file" accept="image/*" onChange={(e) => handleFile(e.target.files?.[0])} hidden />
      </label>
      {status && <small>{status}</small>}
    </div>
  );
}

function FieldInput({ field, value, onChange, uploadType, recordId }) {
  const type = field.type || 'text';
  if (type === 'image') {
    return <ImageInput field={field} value={value} onChange={onChange} uploadType={uploadType} recordId={recordId} />;
  }
  if (type === 'select') {
    return (
      <select
        className="select"
        required={!!field.required}
        value={value ?? ''}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="">Select...</option>
        {(field.options || []).map((opt) => (
          <option key={opt.value} value={opt.value}>{opt.label}</option>
        ))}
      </select>
    );
  }
  if (type === 'textarea') {
    return (
      <textarea
        required={!!field.required}
        placeholder={field.placeholder || ''}
        value={value ?? ''}
        onChange={(e) => onChange(e.target.value)}
      />
    );
  }
  if (type === 'checkbox') {
    return (
      <input
        type="checkbox"
        checked={!!value}
        onChange={(e) => onChange(e.target.checked ? 1 : 0)}
      />
    );
  }
  return (
    <input
      className="input"
      type={type}
      required={!!field.required}
      value={value ?? ''}
      onChange={(e) => onChange(e.target.value)}
    />
  );
}

// config: {
//   title, singular, description, endpoint, columns: [{key,label,badge}],
//   fields: [{name,label,type,required,options,hideOnAdd}],
//   completenessFields: [], hideAdd, canEdit, canDelete, rowLink(row)
// }
export default function ModulePage({ config, extraDetailActions: ExtraDetailActions, extraToolbarActions: ExtraToolbarActions }) {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [search, setSearch] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [addForm, setAddForm] = useState({});
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState('');
  const [selected, setSelected] = useState(null);
  const [editMode, setEditMode] = useState(false);
  const [editForm, setEditForm] = useState({});

  async function load() {
    setLoading(true);
    setLoadError('');
    try {
      const res = await fetch(config.listUrl || config.endpoint);
      const json = await res.json();
      if (!json.success) throw new Error(json.error || 'Failed to load.');
      setRows(json.data || []);
    } catch (e) {
      setLoadError(e.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, [config.endpoint, config.listUrl]);

  const filteredRows = useMemo(() => {
    if (!search.trim()) return rows;
    const q = search.toLowerCase();
    return rows.filter((row) => Object.values(row).some((v) => v !== null && String(v).toLowerCase().includes(q)));
  }, [rows, search]);

  function fieldsForAdd() {
    return config.fields.filter((f) => !f.hideOnAdd);
  }

  async function submitAdd(e) {
    e.preventDefault();
    setSaving(true);
    setSaveError('');
    try {
      const res = await fetch(config.endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...addForm, ...(config.fixedFields || {}) }),
      });
      const json = await res.json();
      if (!json.success) throw new Error(json.error || 'Save failed.');
      setShowAdd(false);
      setAddForm({});
      await load();
    } catch (e) {
      setSaveError(e.message);
    } finally {
      setSaving(false);
    }
  }

  function openDetail(row) {
    setSelected(row);
    setEditForm(row);
    setEditMode(false);
  }

  async function submitEdit(e) {
    e.preventDefault();
    setSaving(true);
    setSaveError('');
    try {
      const res = await fetch(`${config.endpoint}/${selected.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(editForm),
      });
      const json = await res.json();
      if (!json.success) throw new Error(json.error || 'Update failed.');
      setSelected(null);
      await load();
    } catch (e) {
      setSaveError(e.message);
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!confirm(`Delete this ${config.singular.toLowerCase()}?`)) return;
    setSaving(true);
    try {
      const res = await fetch(`${config.endpoint}/${selected.id}`, { method: 'DELETE' });
      const json = await res.json();
      if (!json.success) throw new Error(json.error || 'Delete failed.');
      setSelected(null);
      await load();
    } catch (e) {
      setSaveError(e.message);
    } finally {
      setSaving(false);
    }
  }

  const completeness = config.completenessFields || [];

  return (
    <div>
      <div className="toolbar">
        <div>
          <h2 className="section-title">{config.title}</h2>
          {config.description && <div className="subtle">{config.description}</div>}
        </div>
        <div className="toolbar-left">
          <input className="input" placeholder={`Search ${config.title.toLowerCase()}`} value={search} onChange={(e) => setSearch(e.target.value)} />
          {ExtraToolbarActions && <ExtraToolbarActions />}
          {!config.hideAdd && (
            <button className="btn btn-primary" type="button" onClick={() => { setAddForm({}); setSaveError(''); setShowAdd(true); }}>
              <Plus className="icon" /> Add {config.singular}
            </button>
          )}
        </div>
      </div>

      {loadError && <div className="alert alert-danger">{loadError}</div>}

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              {completeness.length > 0 && <th className="status-dot-head"></th>}
              {config.columns.map((col) => <th key={col.key}>{col.label}</th>)}
              <th></th>
            </tr>
          </thead>
          <tbody>
            {!loading && filteredRows.length === 0 && (
              <tr><td className="empty" colSpan={config.columns.length + 1 + (completeness.length ? 1 : 0)}>No records yet.</td></tr>
            )}
            {loading && (
              <tr><td className="empty" colSpan={config.columns.length + 1 + (completeness.length ? 1 : 0)}>Loading…</td></tr>
            )}
            {filteredRows.map((row) => {
              const missing = completeness.filter((f) => row[f] === null || String(row[f] ?? '').trim() === '');
              const isComplete = missing.length === 0;
              return (
                <tr key={row.id} data-record onClick={() => openDetail(row)} style={{ cursor: 'pointer' }}>
                  {completeness.length > 0 && (
                    <td className="status-dot-cell">
                      <span
                        className={`completion-dot ${isComplete ? 'complete' : 'incomplete'}`}
                        title={isComplete ? 'Complete record' : `Missing: ${missing.join(', ')}`}
                      />
                    </td>
                  )}
                  {config.columns.map((col) => (
                    <td key={col.key}>
                      {col.badge ? <Badge value={row[col.key]} /> : String(row[col.key] ?? '')}
                    </td>
                  ))}
                  <td className="actions">
                    <button className="btn btn-small" type="button" onClick={(e) => { e.stopPropagation(); openDetail(row); }}>View</button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {showAdd && (
        <div className="modal-backdrop open">
          <div className="modal">
            <header>
              <h2>Add {config.singular}</h2>
              <button className="btn btn-small" type="button" onClick={() => setShowAdd(false)}><X size={14} /></button>
            </header>
            <form onSubmit={submitAdd}>
              <div className="form-grid">
                {fieldsForAdd().map((field) => (
                  <div key={field.name} className={`form-row ${['textarea', 'checklist', 'image'].includes(field.type) ? 'full' : ''}`}>
                    <label>{field.label}</label>
                    <FieldInput
                      field={field}
                      value={addForm[field.name]}
                      uploadType={config.uploadType}
                      recordId={0}
                      onChange={(v) => setAddForm((f) => ({ ...f, [field.name]: v }))}
                    />
                  </div>
                ))}
              </div>
              {saveError && <div className="alert alert-danger" style={{ margin: '0 13px 13px' }}>{saveError}</div>}
              <footer>
                <button className="btn" type="button" onClick={() => setShowAdd(false)}>Cancel</button>
                <button className="btn btn-primary" type="submit" disabled={saving}>{saving ? 'Saving…' : `Save ${config.singular}`}</button>
              </footer>
            </form>
          </div>
        </div>
      )}

      {selected && (
        <div className="modal-backdrop open">
          <div className="modal" style={{ width: 'min(900px,96vw)' }}>
            <header>
              <h2>{config.singular} Details</h2>
              <div style={{ display: 'flex', gap: 8 }}>
                {ExtraDetailActions && <ExtraDetailActions record={selected} onDone={() => { setSelected(null); load(); }} />}
                {(config.canEdit ?? true) && !editMode && (
                  <button className="btn btn-small" type="button" onClick={() => setEditMode(true)}>Edit</button>
                )}
                {(config.canDelete ?? true) && (
                  <button className="btn btn-small btn-danger" type="button" onClick={handleDelete}>Delete</button>
                )}
                <button className="btn btn-small" type="button" onClick={() => setSelected(null)}><X size={14} /></button>
              </div>
            </header>

            {!editMode && config.imageField && (
              <div className="record-profile-row">
                <div className="record-image-pane">
                  {selected[config.imageField] ? (
                    <a href={normalizeImageUrl(selected[config.imageField])} target="_blank" rel="noreferrer">
                      <img src={normalizeImageUrl(selected[config.imageField])} alt={`${config.singular} photo`} />
                    </a>
                  ) : (
                    <div className="record-image-placeholder">No photo</div>
                  )}
                </div>
                <div>
                  <h3>{selected.fleet_number || selected.full_name || selected.registration || `${config.singular} Details`}</h3>
                  <div className="record-profile-badges">
                    {selected.registration && <span className="badge">{selected.registration}</span>}
                    {selected.department && <span className="badge">{selected.department}</span>}
                    {selected.status && <Badge value={selected.status} />}
                  </div>
                </div>
              </div>
            )}

            {!editMode && (
              <div className="detail-grid">
                {config.fields.filter((field) => field.name !== config.imageField).map((field) => (
                  <div className="detail-item" key={field.name}>
                    <span>{field.label}</span>
                    <strong>
                      {field.type === 'select'
                        ? (field.options || []).find((o) => String(o.value) === String(selected[field.name]))?.label ?? String(selected[field.name] ?? '—')
                        : String(selected[field.name] ?? '—')}
                    </strong>
                  </div>
                ))}
              </div>
            )}

            {editMode && (
              <form onSubmit={submitEdit}>
                <div className="form-grid">
                  {config.fields.map((field) => (
                    <div key={field.name} className={`form-row ${['textarea', 'checklist', 'image'].includes(field.type) ? 'full' : ''}`}>
                      <label>{field.label}</label>
                      <FieldInput
                        field={field}
                        value={editForm[field.name]}
                        uploadType={config.uploadType}
                        recordId={selected.id}
                        onChange={(v) => setEditForm((f) => ({ ...f, [field.name]: v }))}
                      />
                    </div>
                  ))}
                </div>
                {saveError && <div className="alert alert-danger" style={{ margin: '0 13px 13px' }}>{saveError}</div>}
                <footer>
                  <button className="btn" type="button" onClick={() => setEditMode(false)}>Cancel</button>
                  <button className="btn btn-primary" type="submit" disabled={saving}>{saving ? 'Saving…' : 'Save Changes'}</button>
                </footer>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
