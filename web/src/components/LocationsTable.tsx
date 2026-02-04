import { Button, Card, Spacer, Table, Text } from "@geist-ui/core";
import { useCallback, useMemo, useState } from "react";
import {
  useDeleteLocation,
  useGetLocations,
} from "../api_controllers/useLocations";
import type { LocationType } from "../api/Locations";
import AddLocationForm from "./AddLocationForm";

export default function LocationsTable() {
  const { data: locations, loading, error, refetch } = useGetLocations();
  const { deleteLocation, loading: deleting, error: deleteError } =
    useDeleteLocation();
  const [open, setOpen] = useState(false);

  const handleDelete = useCallback(
    async (row: LocationType) => {
      if (!window.confirm(`Delete location "${row.name}"?`)) return;
      try {
        await deleteLocation(row.id);
        void refetch();
      } catch {
        // Error surfaced by useDeleteLocation
      }
    },
    [deleteLocation, refetch],
  );

  const tableData = useMemo(() => {
    return (locations ?? []).map((row) => ({
      ...row,
      actions: (
        // @ts-expect-error Geist Button typing is overly strict here
        <Button
          auto
          type="error"
          loading={deleting}
          onClick={() => handleDelete(row)}
        >
          Delete
        </Button>
      ),
    }));
  }, [locations, deleting, handleDelete]);

  return (
    <Card>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Text h3>Locations</Text>
        {/* @ts-expect-error Geist Button typing is overly strict here */}
        <Button onClick={() => setOpen(true)} type="secondary">
          Add Location
        </Button>
      </div>
      {loading && <Text p>Loading…</Text>}
      {error && !loading && <Text p>{error}</Text>}
      {deleteError && <Text p type="error">{deleteError}</Text>}
      {!loading && !error && (
        <>
          <Spacer h={0.5} />
          <Table data={tableData}>
            <Table.Column prop="id" label="ID" />
            <Table.Column prop="name" label="Name" />
            <Table.Column prop="type" label="Type" />
            <Table.Column prop="latitude" label="Lat" />
            <Table.Column prop="longitude" label="Lng" />
            <Table.Column prop="createdAt" label="Created" />
            <Table.Column prop="actions" label="Actions" />
          </Table>
          <AddLocationForm
            open={open}
            setOpen={setOpen}
            onSuccess={() => {
              setOpen(false);
              void refetch();
            }}
          />
        </>
      )}
    </Card>
  );
}
