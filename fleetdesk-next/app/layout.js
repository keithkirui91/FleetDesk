import './globals.css';

export const metadata = {
  title: 'Kamok FleetDesk',
  description: 'Garage & fleet management',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
