const API_BASE_URL = import.meta.env.VITE_API_URL ?? "http://localhost:3000";

let tokenGetter: (() => Promise<string>) | null = null;

export function setTokenGetter(getter: (() => Promise<string>) | null) {
  tokenGetter = getter;
}

export async function getAuthHeaders(): Promise<Record<string, string>> {
  const headers: Record<string, string> = {};
  if (tokenGetter) {
    try {
      const token = await tokenGetter();
      if (token) {
        headers["Authorization"] = `Bearer ${token}`;
      }
    } catch {
      // Token may have expired or user logged out - continue without it
    }
  }
  return headers;
}

export function getApiBaseUrl(): string {
  return API_BASE_URL;
}
