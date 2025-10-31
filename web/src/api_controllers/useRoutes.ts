import { useEffect, useState } from "react";
import {
  createRoute as createRouteApi,
  deleteRoute as deleteRouteApi,
  getRoute,
  getRoutes,
  type CreateRouteInput,
  type RouteType,
  type UpdateRouteInput,
  updateRoute as updateRouteApi,
} from "../api/Routes";

export function useGetRoutes() {
  const [data, setData] = useState<RouteType[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchAll = async () => {
    setLoading(true);
    try {
      const rows = await getRoutes();
      setData(rows);
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void fetchAll();
  }, []);

  return { data, loading, error, refetch: fetchAll } as const;
}

export function useGetRoute(id: string | null) {
  const [data, setData] = useState<RouteType | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const fetchRoute = async (routeId: string) => {
    setLoading(true);
    try {
      const route = await getRoute(routeId);
      setData(route);
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) {
      void fetchRoute(id);
    }
  }, [id]);

  return { data, loading, error, refetch: fetchRoute } as const;
}

export function useCreateRoute() {
  const [data, setData] = useState<RouteType | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const createRoute = async (route: CreateRouteInput) => {
    try {
      setLoading(true);
      const newRoute = await createRouteApi(route);
      setData(newRoute);
      setError(null);
      return newRoute;
    } catch (e) {
      const errorMessage = e instanceof Error ? e.message : "Unknown error";
      setError(errorMessage);
      throw e;
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, createRoute } as const;
}

export function useUpdateRoute() {
  const [data, setData] = useState<RouteType | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const updateRoute = async (id: string, route: UpdateRouteInput) => {
    try {
      setLoading(true);
      const updatedRoute = await updateRouteApi(id, route);
      setData(updatedRoute);
      setError(null);
      return updatedRoute;
    } catch (e) {
      const errorMessage = e instanceof Error ? e.message : "Unknown error";
      setError(errorMessage);
      throw e;
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, updateRoute } as const;
}

export function useDeleteRoute() {
  const [data, setData] = useState<RouteType | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const deleteRoute = async (id: string) => {
    try {
      setLoading(true);
      const deletedRoute = await deleteRouteApi(id);
      setData(deletedRoute);
      setError(null);
      return deletedRoute;
    } catch (e) {
      const errorMessage = e instanceof Error ? e.message : "Unknown error";
      setError(errorMessage);
      throw e;
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, deleteRoute } as const;
}

