import { useEffect, useState } from "react";
import {
  createLocation as createLocationApi,
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
    try {
      setLoading(true);
      const newLocation = await createLocationApi(location);
      setData(newLocation as LocationType);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, createLocation } as const;
}
