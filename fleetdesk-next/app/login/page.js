'use client';

import { Suspense, useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';

export default function LoginPage() {
  return (
    <Suspense fallback={null}>
      <LoginForm />
    </Suspense>
  );
}

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [dbReady, setDbReady] = useState(true);
  const [loading, setLoading] = useState(false);
  const timeout = searchParams.get('timeout');

  useEffect(() => {
    fetch('/api/auth/me').then((r) => r.json()).then((data) => {
      if (data.needsSetup) router.replace('/auth-setup');
      setDbReady(data.dbReady);
    });
  }, [router]);

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    if (!username.trim() || !password) {
      setError('Please enter your username and password.');
      return;
    }
    setLoading(true);
    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: username.trim(), password }),
      });
      const data = await res.json();
      if (!data.success) {
        setError(data.error || 'Invalid username or password.');
        return;
      }
      router.push(data.redirect || '/dashboard');
      router.refresh();
    } catch {
      setError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-page">
      <main className="login-card">
        <h1>Kamok FleetDesk</h1>
        <p>Sign in to manage vehicles, jobs, services, fuel, mileage, and mechanics.</p>
        {!dbReady && <div className="alert alert-danger">Database is not ready. Import schema.sql and check your .env.local.</div>}
        {timeout !== null && <div className="alert">Session expired. Please sign in again.</div>}
        {error && <div className="alert alert-danger">{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className="form-row">
            <label htmlFor="username">Username</label>
            <input className="input" id="username" autoComplete="username" required autoFocus value={username} onChange={(e) => setUsername(e.target.value)} />
          </div>
          <div className="form-row">
            <label htmlFor="password">Password</label>
            <input className="input" id="password" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
          </div>
          <button className="btn btn-primary" type="submit" disabled={loading}>{loading ? 'Signing in…' : 'Sign in'}</button>
          <a className="btn" href="/auth-setup">Admin setup</a>
        </form>
      </main>
    </div>
  );
}
