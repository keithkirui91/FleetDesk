import crypto from 'crypto';

const SECRET = process.env.SESSION_SECRET || 'fleetdesk-dev-secret-change-me';
export const SESSION_COOKIE = 'fleetdesk_session';
export const SESSION_TIMEOUT_SECONDS = 8 * 60 * 60; // 28800s, matches original SESSION_TIMEOUT

function sign(payloadB64) {
  return crypto.createHmac('sha256', SECRET).update(payloadB64).digest('base64url');
}

// Encode a session payload into "base64(json).signature"
export function encodeSession(data) {
  const payload = { ...data, iat: Math.floor(Date.now() / 1000) };
  const payloadB64 = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const sig = sign(payloadB64);
  return `${payloadB64}.${sig}`;
}

// Decode + verify a session cookie value. Returns null if missing/invalid/expired.
export function decodeSession(cookieValue) {
  if (!cookieValue) return null;
  const [payloadB64, sig] = cookieValue.split('.');
  if (!payloadB64 || !sig) return null;
  const expectedSig = sign(payloadB64);
  if (!crypto.timingSafeEqual(Buffer.from(sig), Buffer.from(expectedSig))) return null;

  let data;
  try {
    data = JSON.parse(Buffer.from(payloadB64, 'base64url').toString('utf8'));
  } catch {
    return null;
  }

  const age = Math.floor(Date.now() / 1000) - (data.iat || 0);
  if (age > SESSION_TIMEOUT_SECONDS) return null;

  return data;
}

// Lightweight, unverified peek at the session payload for use in Edge
// middleware (which can't use Node's crypto module). This is ONLY used for
// routing/redirect decisions — every API route still calls decodeSession()
// (full HMAC verification, Node runtime) before trusting the session.
export function peekSessionUnsafe(cookieValue) {
  if (!cookieValue) return null;
  const [payloadB64] = cookieValue.split('.');
  if (!payloadB64) return null;
  try {
    const data = JSON.parse(Buffer.from(payloadB64, 'base64url').toString('utf8'));
    const age = Math.floor(Date.now() / 1000) - (data.iat || 0);
    if (age > SESSION_TIMEOUT_SECONDS) return null;
    return data;
  } catch {
    return null;
  }
}

export const cookieOptions = {
  httpOnly: true,
  sameSite: 'lax',
  path: '/',
  maxAge: SESSION_TIMEOUT_SECONDS,
};
