import { readFile } from 'node:fs/promises';
const source = await readFile(new URL('../src/cloud/config.js', import.meta.url), 'utf8');
const { isConfigured } = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
if (!isConfigured()) {
  console.error('Missing or invalid Supabase configuration. Edit .env using .env.example and use the publishable key (not a secret key).');
  process.exitCode = 1;
} else {
  console.log('Supabase configuration format OK. This does not test network access or key validity.');
}
