import { NextResponse } from 'next/server';
import { SESSION_COOKIE, peekSessionUnsafe } from './lib/session';

const ADMIN_PATHS = [
  '/dashboard',
  '/fleet',
  '/drivers',
  '/mechanics',
  '/jobs',
  '/services',
  '/fuel',
  '/fuel-delivery',
  '/dip-readings',
  '/mileage',
  '/driver-allocations',
  '/disposed-assets',
  '/battery-logs',
  '/tyre-logs',
  '/reports',
];

const GATE_PATHS = ['/gate-mileage'];

export function middleware(request) {
  const { pathname } = request.nextUrl;
  const session = peekSessionUnsafe(request.cookies.get(SESSION_COOKIE)?.value);

  const needsAdmin = ADMIN_PATHS.some((p) => pathname === p || pathname.startsWith(p + '/'));
  const needsGate = GATE_PATHS.some((p) => pathname === p || pathname.startsWith(p + '/'));

  if (needsAdmin) {
    if (!session || session.type !== 'admin') {
      return NextResponse.redirect(new URL('/login', request.url));
    }
  }

  if (needsGate) {
    if (!session || (session.type !== 'data_entry' && session.type !== 'admin')) {
      return NextResponse.redirect(new URL('/login', request.url));
    }
  }

  // Already signed in? Skip the login page.
  if (pathname === '/login' && session?.type === 'admin') {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }
  if (pathname === '/login' && session?.type === 'data_entry') {
    return NextResponse.redirect(new URL('/gate-mileage', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/fleet/:path*',
    '/drivers/:path*',
    '/mechanics/:path*',
    '/jobs/:path*',
    '/services/:path*',
    '/fuel/:path*',
    '/fuel-delivery/:path*',
    '/dip-readings/:path*',
    '/mileage/:path*',
    '/driver-allocations/:path*',
    '/disposed-assets/:path*',
    '/battery-logs/:path*',
    '/tyre-logs/:path*',
    '/reports/:path*',
    '/gate-mileage/:path*',
    '/login',
  ],
};
