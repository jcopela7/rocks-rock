import { Button, Card, Spacer, Table, Text } from "@geist-ui/core";
import { useState } from "react";
import { useGetRoutes } from "../api_controllers/useRoutes";
import AddRouteForm from "./AddRouteForm";

export default function RoutesTable() {
  const { data: routes, loading, error, refetch } = useGetRoutes();
  const [open, setOpen] = useState(false);

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
      {!loading && !error && (
        <>
          <Spacer h={0.5} />
          <Table data={routes}>
            <Table.Column prop="name" label="Name" />
            <Table.Column prop="discipline" label="Discipline" />
            <Table.Column prop="gradeSystem" label="Grade System" />
            <Table.Column prop="gradeValue" label="Grade" />
            <Table.Column prop="gradeRank" label="Grade Rank" />
            <Table.Column prop="locationId" label="Location ID" />
            <Table.Column prop="createdAt" label="Created" />
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

