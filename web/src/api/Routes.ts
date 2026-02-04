import { getApiBaseUrl, getAuthHeaders } from "./client";

export type RouteType = {
  id: string;
  locationId: string;
  name: string | null;
  discipline: "boulder" | "sport" | "trad";
  gradeSystem: "V" | "YDS" | "Font";
  gradeValue: string;
  gradeRank: number;
  color: string | null;
  createdAt?: string;
  updatedAt?: string;
  deletedAt?: string | null;
};

export async function getRoutes(): Promise<RouteType[]> {
  const headers = await getAuthHeaders();
  const res = await fetch(`${getApiBaseUrl()}/api/v1/route`, { headers });
  if (!res.ok) {
    throw new Error(`Failed to fetch routes: ${res.status}`);
  }
  const json = (await res.json()) as { data: unknown[] };
  return json.data as RouteType[];
}

export async function getRoute(id: string): Promise<RouteType> {
  const headers = await getAuthHeaders();
  const res = await fetch(`${getApiBaseUrl()}/api/v1/route/${id}`, { headers });
  if (!res.ok) {
    throw new Error(`Failed to fetch route: ${res.status}`);
  }
  const json = (await res.json()) as { data: unknown };
  return json.data as RouteType;
}

export type CreateRouteInputType = {
  id?: string;
  locationId: string;
  name?: string;
  discipline: "boulder" | "sport" | "trad";
  gradeSystem: "V" | "YDS" | "Font";
  gradeValue: string;
  gradeRank: number;
  color?: string;
};

export async function createRoute(route: CreateRouteInputType): Promise<RouteType> {
  const authHeaders = await getAuthHeaders();
  const res = await fetch(`${getApiBaseUrl()}/api/v1/route`, {
    method: "POST",
    headers: { "Content-Type": "application/json", ...authHeaders },
    body: JSON.stringify(route),
  });
  if (!res.ok) {
    throw new Error(`Failed to create route: ${res.status}`);
  }
  return res.json() as Promise<RouteType>;
}

export type UpdateRouteInputType = {
  locationId?: string;
  name?: string;
  discipline?: "boulder" | "sport" | "trad";
  gradeSystem?: "V" | "YDS" | "Font";
  gradeValue?: string;
  gradeRank?: number;
  color?: string;
};

export async function updateRoute(
  id: string,
  route: UpdateRouteInputType,
): Promise<RouteType> {
  const authHeaders = await getAuthHeaders();
  const res = await fetch(`${getApiBaseUrl()}/api/v1/route/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json", ...authHeaders },
    body: JSON.stringify(route),
  });
  if (!res.ok) {
    throw new Error(`Failed to update route: ${res.status}`);
  }
  const json = (await res.json()) as { data: unknown };
  return json.data as RouteType;
}

export async function deleteRoute(id: string): Promise<RouteType> {
  const headers = await getAuthHeaders();
  const res = await fetch(`${getApiBaseUrl()}/api/v1/route/${id}`, {
    method: "DELETE",
    headers,
  });
  if (!res.ok) {
    throw new Error(`Failed to delete route: ${res.status}`);
  }
  const json = (await res.json()) as { data: unknown };
  return json.data as RouteType;
}

