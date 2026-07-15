import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';
import { SESSION_COOKIE, decodeSession } from './session';

// Returns the decoded session (or null) for the current request. Usable in
// server components, route handlers, and layouts.
export function getSession() {
  const raw = cookies().get(SESSION_COOKIE)?.value;
  return decodeSession(raw);
}

export function isAdmin(session) {
  return !!session && session.type === 'admin';
}

export function isDataEntry(session) {
  return !!session && session.type === 'data_entry';
}

// Guard for API routes that require an admin session (mirrors api/common.php).
// data_entry users are only allowed to hit the odometer endpoint.
export function requireApiSession(request, { allowDataEntry = false } = {}) {
  const session = getSession();
  if (!session) {
    return { session: null, error: NextResponse.json({ success: false, error: 'Authentication required.' }, { status: 401 }) };
  }
  if (session.type === 'data_entry' && !allowDataEntry) {
    return { session: null, error: NextResponse.json({ success: false, error: 'Data entry users can only log mileage.' }, { status: 403 }) };
  }
  return { session, error: null };
}

export function jsonError(message, status = 400) {
  return NextResponse.json({ success: false, error: message }, { status });
}

export function jsonSuccess(data = null, extra = {}) {
  return NextResponse.json({ success: true, data, ...extra });
}
