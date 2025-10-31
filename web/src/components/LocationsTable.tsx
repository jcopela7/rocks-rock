import { Button, Card, Spacer, Table, Text } from "@geist-ui/core";
import { useState } from "react";
import { useGetLocations } from "../api_controllers/useLocations";
import AddLocationForm from "./AddLocationForm";

export default function LocationsTable() {
  const { data: locations, loading, error, refetch } = useGetLocations();
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
        <Text h3>Locations</Text>
        {/* @ts-expect-error Geist Button typing is overly strict here */}
        <Button onClick={() => setOpen(true)} type="secondary">
          Add Location
        </Button>
      </div>
      {loading && <Text p>Loading…</Text>}
      {error && !loading && <Text p>{error}</Text>}
      {!loading && !error && (
        <>
          <Spacer h={0.5} />
          <Table data={locations}>
            <Table.Column prop="name" label="Name" />
            <Table.Column prop="type" label="Type" />
            <Table.Column prop="latitude" label="Lat" />
            <Table.Column prop="longitude" label="Lng" />
            <Table.Column prop="created_at" label="Created" />
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
