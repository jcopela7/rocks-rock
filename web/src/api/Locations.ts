import { getApiBaseUrl, getAuthHeaders } from "./client";

export type LocationType = {
  id: string;
  name: string;
  type: string;
  latitude: number | null;
  longitude: number | null;
  created_at?: string;
  updated_at?: string;
};

export async function getLocations(): Promise<LocationType[]> {
  const headers = await getAuthHeaders();
  const res = await fetch(`${getApiBaseUrl()}/api/v1/location`, { headers });
  if (!res.ok) {
    throw new Error(`Failed to fetch locations: ${res.status}`);
  }
  const json = (await res.json()) as { data: unknown[] };
  return json.data as LocationType[];
}

export type CreateLocationInput = {
  id: string;
  name: string;
  type: "gym" | "crag";
  latitude?: number | null;
  longitude?: number | null;
  createdBy: string;
};

export async function createLocation(
  location: CreateLocationInput,
): Promise<LocationType> {
  const authHeaders = await getAuthHeaders();
  const res = await fetch(`${getApiBaseUrl()}/api/v1/location`, {
    method: "POST",
    headers: { "Content-Type": "application/json", ...authHeaders },
    body: JSON.stringify(location),
  });
  if (!res.ok) {
    throw new Error(`Failed to create location: ${res.status}`);
  }
  return res.json() as Promise<LocationType>;
}
