import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    currency: 'KES',
    city: 'Nairobi',
    valid_until: '2026-06-14',
    source: 'EPRA May/June 2026 maximum pump prices, Nairobi fallback',
    prices: {
      petrol: 214.25,
      diesel: 232.86,
      kerosene: 191.38,
      hybrid: 214.25,
      lpg: 0,
      other: 0,
    },
  });
}
