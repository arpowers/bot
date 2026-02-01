#!/usr/bin/env node
/**
 * Get Google access token from service account
 * Usage: node google-sa-token.js [scope]
 *
 * Reads GOOGLE_SERVICE_ACCOUNT env var (base64-encoded JSON)
 * Outputs just the access token to stdout
 */

const crypto = require('crypto');
const https = require('https');

const SCOPES = process.argv[2] || 'https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/spreadsheets';

async function getToken() {
  // Decode service account from env
  const saBase64 = process.env.GOOGLE_SERVICE_ACCOUNT;
  if (!saBase64) {
    console.error('GOOGLE_SERVICE_ACCOUNT env var not set');
    process.exit(1);
  }

  let sa;
  try {
    sa = JSON.parse(Buffer.from(saBase64, 'base64').toString('utf8'));
  } catch (e) {
    console.error('Failed to parse GOOGLE_SERVICE_ACCOUNT:', e.message);
    process.exit(1);
  }

  // Create JWT
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: sa.client_email,
    scope: SCOPES,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600
  };

  const headerB64 = Buffer.from(JSON.stringify(header)).toString('base64url');
  const payloadB64 = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const unsigned = `${headerB64}.${payloadB64}`;

  // Sign with private key
  const sign = crypto.createSign('RSA-SHA256');
  sign.update(unsigned);
  const signature = sign.sign(sa.private_key, 'base64url');
  const jwt = `${unsigned}.${signature}`;

  // Exchange JWT for access token
  const postData = `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`;

  return new Promise((resolve, reject) => {
    const req = https.request({
      hostname: 'oauth2.googleapis.com',
      path: '/token',
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': postData.length
      }
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.access_token) {
            console.log(json.access_token);
            resolve();
          } else {
            console.error('Token error:', json);
            process.exit(1);
          }
        } catch (e) {
          console.error('Parse error:', e.message);
          process.exit(1);
        }
      });
    });
    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

getToken().catch(e => {
  console.error(e);
  process.exit(1);
});
