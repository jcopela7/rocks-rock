import { useEffect, useState } from "react";
import {
  createLocation as createLocationApi,
  deleteLocation as deleteLocationApi,
  getLocations,
  type CreateLocationInput,
  type LocationType,
} from "../api/Locations";

export function useGetLocations() {
  const [data, setData] = useState<LocationType[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchAll = async () => {
    setLoading(true);
    try {
      const rows = await getLocations();
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

export function useCreateLocation() {
  const [data, setData] = useState<LocationType | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const createLocation = async (location: CreateLocationInput) => {
    setLoading(true);
    setError(null);
    try {
      const newLocation = await createLocationApi(location);
      setData(newLocation as LocationType);
      return newLocation as LocationType;
    } catch (e) {
      const message = e instanceof Error ? e.message : "Unknown error";
      setError(message);
      throw e;
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, createLocation } as const;
}

export function useDeleteLocation() {
  const [data, setData] = useState<LocationType | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const deleteLocation = async (id: string) => {
    try {
      setLoading(true);
      const deleted = await deleteLocationApi(id);
      setData(deleted);
      setError(null);
      return deleted;
    } catch (e) {
      const errorMessage = e instanceof Error ? e.message : "Unknown error";
      setError(errorMessage);
      throw e;
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, deleteLocation } as const;
}
