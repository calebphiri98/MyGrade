// Expo embeds EXPO_PUBLIC_ values into the client bundle. Only public keys here.
// Gemini and database/service-role secrets must stay on the server.
export const SUPABASE_URL = (process.env.EXPO_PUBLIC_SUPABASE_URL || '').trim().replace(/\/+$/, '');
export const SUPABASE_ANON_KEY = (process.env.EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY || '').trim();

export function isConfigured() {
  return SUPABASE_URL !== "https://your-project-ref.supabase.co" &&
    SUPABASE_ANON_KEY !== "sb_publishable_REPLACE_ME" &&
    /^https:\/\/[a-z0-9-]+\.supabase\.co$/i.test(SUPABASE_URL) &&
    /^sb_publishable_[A-Za-z0-9_-]+$/.test(SUPABASE_ANON_KEY);
}
