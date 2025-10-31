const API_BASE_URL = import.meta.env.VITE_API_URL ?? "http://localhost:3000";

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
  const res = await fetch(`${API_BASE_URL}/api/v1/location`);
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
  const res = await fetch(`${API_BASE_URL}/api/v1/location`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(location),
  });
  if (!res.ok) {
    throw new Error(`Failed to create location: ${res.status}`);
  }
  return res.json() as Promise<LocationType>;
}
