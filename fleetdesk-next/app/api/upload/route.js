import { NextResponse } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import path from 'path';
import { getSession } from '@/lib/auth';
import { getPool } from '@/lib/db';

const TARGET_MAP = {
  vehicle: { table: 'vehicles', column: 'primary_image_url', folder: 'vehicles' },
  mechanic: { table: 'mechanics', column: 'photo_url', folder: 'mechanics' },
  driver: { table: 'drivers', column: 'photo_url', folder: 'drivers' },
};

const ALLOWED_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'];
const MAX_SIZE = 5 * 1024 * 1024;

export async function POST(request) {
  const session = getSession();
  if (!session) {
    return NextResponse.json({ error: 'Unauthorised' }, { status: 401 });
  }

  const { searchParams } = new URL(request.url);
  const type = searchParams.get('type') || 'vehicle';
  const id = Number(searchParams.get('id') || 0);
  const target = TARGET_MAP[type] || { table: null, column: null, folder: 'misc' };

  const formData = await request.formData();
  const file = formData.get('image');
  if (!file || typeof file === 'string') {
    return NextResponse.json({ error: 'No file uploaded' }, { status: 400 });
  }
  if (!ALLOWED_TYPES.includes(file.type)) {
    return NextResponse.json({ error: 'Only JPG, PNG, WEBP and GIF images are allowed' }, { status: 400 });
  }
  if (file.size > MAX_SIZE) {
    return NextResponse.json({ error: 'Image must be under 5MB' }, { status: 400 });
  }

  const uploadDir = path.join(process.cwd(), 'public', 'uploads', target.folder);
  await mkdir(uploadDir, { recursive: true });

  const ext = (file.name.split('.').pop() || 'jpg').toLowerCase();
  const filename = `${type}_${id}_${Date.now()}.${ext}`;
  const dest = path.join(uploadDir, filename);

  const buffer = Buffer.from(await file.arrayBuffer());
  await writeFile(dest, buffer);

  const storedPath = `/uploads/${target.folder}/${filename}`;

  if (id && target.table) {
    await getPool().query(`UPDATE ${target.table} SET ${target.column} = ? WHERE id = ?`, [storedPath, id]);
  }

  return NextResponse.json({ success: true, url: storedPath, stored_path: storedPath, filename });
}
