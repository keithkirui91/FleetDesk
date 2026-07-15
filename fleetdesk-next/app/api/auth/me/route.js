import { NextResponse } from 'next/server';
import { dbValue } from '@/lib/db';
import { getSession } from '@/lib/auth';

export async function GET() {
  const session = getSession();
  let adminCount = -1;
  try {
    adminCount = Number(await dbValue('SELECT COUNT(*) FROM users'));
  } catch {
    adminCount = -1;
  }
  return NextResponse.json({ session, needsSetup: adminCount === 0, dbReady: adminCount >= 0 });
}
