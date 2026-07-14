import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import { dbValue, insertRow } from '@/lib/db';
import { encodeSession, SESSION_COOKIE, cookieOptions } from '@/lib/session';

export async function POST(request) {
  const { username, email, password, confirm_password } = await request.json();

  if (!username || !email || !password) {
    return NextResponse.json({ success: false, error: 'Username, email, and password are required.' }, { status: 400 });
  }
  if (password !== confirm_password) {
    return NextResponse.json({ success: false, error: 'Passwords do not match.' }, { status: 400 });
  }
  if (password.length < 8) {
    return NextResponse.json({ success: false, error: 'Use at least 8 characters for the password.' }, { status: 400 });
  }

  try {
    const count = Number(await dbValue('SELECT COUNT(*) FROM users'));
    if (count > 0) {
      return NextResponse.json({ success: false, error: 'Admin already set. Setup is locked to keep the garage account safe.' }, { status: 409 });
    }

    const hash = await bcrypt.hash(password, 10);
    const id = await insertRow('users', ['username', 'email', 'password_hash', 'role'], {
      username, email, password_hash: hash, role: 'admin',
    });

    const res = NextResponse.json({ success: true, redirect: '/dashboard' });
    res.cookies.set(SESSION_COOKIE, encodeSession({ type: 'admin', id, username }), cookieOptions);
    return res;
  } catch (e) {
    return NextResponse.json({ success: false, error: 'Database is not ready. Import schema.sql and check your .env.local credentials.' }, { status: 500 });
  }
}
