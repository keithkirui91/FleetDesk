import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import { dbOne } from '@/lib/db';
import { encodeSession, SESSION_COOKIE, cookieOptions } from '@/lib/session';

export async function POST(request) {
  const { username, password } = await request.json();

  if (!username || !password) {
    return NextResponse.json({ success: false, error: 'Please enter your username and password.' }, { status: 400 });
  }

  // Hard-coded gate/data-entry login, matches the original app.
  if (username === 'Data Entry' && password === 'Data Entry') {
    const res = NextResponse.json({ success: true, redirect: '/gate-mileage' });
    res.cookies.set(SESSION_COOKIE, encodeSession({ type: 'data_entry', username: 'Data Entry' }), cookieOptions);
    return res;
  }

  try {
    const user = await dbOne('SELECT id, username, password_hash FROM users WHERE username = ? LIMIT 1', [username]);
    if (user && (await bcrypt.compare(password, user.password_hash))) {
      const res = NextResponse.json({ success: true, redirect: '/dashboard' });
      res.cookies.set(SESSION_COOKIE, encodeSession({ type: 'admin', id: user.id, username: user.username }), cookieOptions);
      return res;
    }
  } catch (e) {
    return NextResponse.json({ success: false, error: 'Database connection failed. Check your .env.local credentials.' }, { status: 500 });
  }

  return NextResponse.json({ success: false, error: 'Invalid username or password.' }, { status: 401 });
}
