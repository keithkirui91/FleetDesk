'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function AuthSetupPage() {
  const router = useRouter();
  const [form, setForm] = useState({ username: '', email: '', password: '', confirm_password: '' });
  const [error, setError] = useState('');
  const [created, setCreated] = useState(false);
  const [locked, setLocked] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetch('/api/auth/me').then((r) => r.json()).then((data) => {
      if (!data.needsSetup && data.dbReady) setLocked(true);
    });
  }, []);

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await fetch('/api/auth/setup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (!data.success) {
        setError(data.error);
        if (res.status === 409) setLocked(true);
        return;
      }
      setCreated(true);
    } catch {
      setError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-page">
      <main className="login-card">
        <h1>FleetDesk setup</h1>
        {created ? (
          <>
            <div className="alert alert-ok">Admin saved. You can now sign in.</div>
            <a className="btn btn-primary" href="/login">Go to sign in</a>
          </>
        ) : locked ? (
          <>
            <div className="alert alert-ok">Admin already set. Setup is locked to keep the garage account safe.</div>
            <a className="btn btn-primary" href="/login">Go to sign in</a>
          </>
        ) : (
          <>
            <p>Create the first administrator for this FleetDesk installation.</p>
            {error && <div className="alert alert-danger">{error}</div>}
            <form onSubmit={handleSubmit}>
              <div className="form-row">
                <label htmlFor="username">Username</label>
                <input className="input" id="username" required autoComplete="username" value={form.username} onChange={(e) => setForm((f) => ({ ...f, username: e.target.value }))} />
              </div>
              <div className="form-row">
                <label htmlFor="email">Email</label>
                <input className="input" id="email" type="email" required autoComplete="email" value={form.email} onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))} />
              </div>
              <div className="form-row">
                <label htmlFor="password">Password</label>
                <input className="input" id="password" type="password" required autoComplete="new-password" value={form.password} onChange={(e) => setForm((f) => ({ ...f, password: e.target.value }))} />
              </div>
              <div className="form-row">
                <label htmlFor="confirm_password">Confirm password</label>
                <input className="input" id="confirm_password" type="password" required autoComplete="new-password" value={form.confirm_password} onChange={(e) => setForm((f) => ({ ...f, confirm_password: e.target.value }))} />
              </div>
              <button className="btn btn-primary" type="submit" disabled={loading}>{loading ? 'Saving…' : 'Save admin'}</button>
            </form>
          </>
        )}
      </main>
    </div>
  );
}
