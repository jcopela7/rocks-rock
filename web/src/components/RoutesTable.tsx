import { Button, Card, Spacer, Table, Text } from "@geist-ui/core";
import { useCallback, useMemo, useState } from "react";
import {
  useDeleteRoute,
  useGetRoutes,
} from "../api_controllers/useRoutes";
import type { RouteType } from "../api/Routes";
import AddRouteForm from "./AddRouteForm";

export default function RoutesTable() {
  const { data: routes, loading, error, refetch } = useGetRoutes();
  const { deleteRoute, loading: deleting, error: deleteError } =
    useDeleteRoute();
  const [open, setOpen] = useState(false);

  const handleDelete = useCallback(
    async (row: RouteType) => {
      const name = row.name || row.gradeValue || row.id;
      if (!window.confirm(`Delete route "${name}"?`)) return;
      try {
        await deleteRoute(row.id);
        void refetch();
      } catch {
        // Error surfaced by useDeleteRoute
      }
    },
    [deleteRoute, refetch],
  );

  const tableData = useMemo(() => {
    return (routes ?? []).map((row) => ({
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
  }, [routes, deleting, handleDelete]);

  return (
    <Card>
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Text h3>Routes</Text>
        {/* @ts-expect-error Geist Button typing is overly strict here */}
        <Button onClick={() => setOpen(true)} type="secondary">
          Add Route
        </Button>
      </div>
      {loading && <Text p>Loading…</Text>}
      {error && !loading && <Text p>{error}</Text>}
      {deleteError && <Text p type="error">{deleteError}</Text>}
      {!loading && !error && (
        <>
          <Spacer h={0.5} />
          <Table data={tableData}>
            <Table.Column prop="name" label="Name" />
            <Table.Column prop="discipline" label="Discipline" />
            <Table.Column prop="gradeSystem" label="Grade System" />
            <Table.Column prop="gradeValue" label="Grade" />
            <Table.Column prop="gradeRank" label="Grade Rank" />
            <Table.Column prop="locationId" label="Location ID" />
            <Table.Column prop="createdAt" label="Created" />
            <Table.Column prop="actions" label="Actions" />
          </Table>
          <AddRouteForm
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

