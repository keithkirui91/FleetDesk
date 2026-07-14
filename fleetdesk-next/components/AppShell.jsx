'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  LayoutGrid, Truck, Users, UserCog, Wrench, Calendar, Droplet, Clock,
  BarChart3, LogOut,
} from 'lucide-react';

const NAV_ITEMS = [
  { href: '/dashboard', icon: LayoutGrid, label: 'Dashboard' },
  { href: '/fleet', icon: Truck, label: 'Fleet' },
  { href: '/drivers', icon: Users, label: 'Drivers' },
  { href: '/driver-allocations', icon: Users, label: 'Driver Allocations' },
  { href: '/jobs', icon: Wrench, label: 'Job Cards' },
  { href: '/services', icon: Calendar, label: 'Service' },
  { href: '/fuel', icon: Droplet, label: 'Fuel' },
  { href: '/mechanics', icon: UserCog, label: 'Mechanics' },
  { href: '/mileage', icon: Clock, label: 'Mileage' },
  { href: '/reports', icon: BarChart3, label: 'Reports' },
];

export default function AppShell({ title, username = 'Admin', children }) {
  const pathname = usePathname();
  const router = useRouter();

  async function handleLogout() {
    await fetch('/api/auth/logout', { method: 'POST' });
    router.push('/login');
  }

  const today = new Date().toLocaleDateString('en-GB', { weekday: 'short', day: '2-digit', month: 'short', year: 'numeric' });

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <Link className="brand" href="/dashboard">
          <span className="brand-mark"><Truck className="icon" /></span>
          <span><strong>Kamok FleetDesk</strong><small>Garage Manager</small></span>
        </Link>
        <nav className="nav">
          {NAV_ITEMS.map(({ href, icon: Icon, label }) => (
            <Link key={href} href={href} className={pathname.startsWith(href) ? 'active' : ''}>
              <Icon className="icon" /><span>{label}</span>
            </Link>
          ))}
        </nav>
        <div className="sidebar-user">
          <div>
            <strong>{username}</strong>
            <small>Administrator</small>
          </div>
          <a title="Logout" onClick={handleLogout} style={{ cursor: 'pointer' }}>
            <LogOut className="icon" />
          </a>
        </div>
      </aside>
      <main className="main">
        <header className="topbar">
          <h1>{title}</h1>
          <span>{today}</span>
        </header>
        <section className="content">{children}</section>
      </main>
    </div>
  );
}
