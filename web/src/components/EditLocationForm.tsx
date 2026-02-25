import { Input, Modal, Select, Text } from "@geist-ui/core";
import { useEffect, useState } from "react";
import type { LocationType, UpdateLocationInput } from "../api/Locations";
import { useUpdateLocation } from "../api_controllers/useLocations";

type Props = {
  location: LocationType | null;
  open: boolean;
  setOpen: (open: boolean) => void;
  onSuccess?: () => void;
};

export default function EditLocationForm({
  location,
  open,
  setOpen,
  onSuccess,
}: Props) {
  const { updateLocation, loading, error } = useUpdateLocation();
  const [formData, setFormData] = useState<{
    name: string;
    type: "gym" | "crag" | "board";
    description: string;
    latitude: string;
    longitude: string;
  }>({
    name: "",
    type: "gym",
    description: "",
    latitude: "",
    longitude: "",
  });

  useEffect(() => {
    if (location) {
      setFormData({
        name: location.name ?? "",
        type: (location.type as "gym" | "crag" | "board") ?? "gym",
        description: location.description ?? "",
        latitude: location.latitude != null ? String(location.latitude) : "",
        longitude:
          location.longitude != null ? String(location.longitude) : "",
      });
    }
  }, [location]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!location || !formData.name || !formData.type) return;

    const payload: UpdateLocationInput = {
      name: formData.name,
      type: formData.type,
      description: formData.description || null,
      ...(formData.latitude ? { latitude: Number.parseFloat(formData.latitude) } : {}),
      ...(formData.longitude ? { longitude: Number.parseFloat(formData.longitude) } : {}),
    };

    try {
      await updateLocation(location.id, payload);
      setOpen(false);
      onSuccess?.();
    } catch {
      // Error surfaced by useUpdateLocation
    }
  };

  const handleChange = (
    field: keyof typeof formData,
    value: string,
  ) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  if (!location) return null;

  return (
    <Modal visible={open} onClose={() => setOpen(false)}>
      <Modal.Title>Edit Location</Modal.Title>
      <Modal.Content>
        {error && (
          <Text type="error" small style={{ marginBottom: 8 }}>
            {error}
          </Text>
        )}
        <form id="edit-location-form" onSubmit={handleSubmit}>
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Location Name"
            id="edit-location-name"
            name="name"
            htmlType="text"
            placeholder="Enter location name"
            value={formData.name}
            onChange={(e) => handleChange("name", e.target.value)}
            required
          />
          {/* @ts-expect-error Geist Select typing is overly strict here */}
          <Select
            placeholder="Select location type"
            value={formData.type}
            onChange={(value) => handleChange("type", value as string)}
          >
            <Select.Option value="gym">Gym</Select.Option>
            <Select.Option value="crag">Crag</Select.Option>
            <Select.Option value="board">Board</Select.Option>
          </Select>
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Description"
            id="edit-location-description"
            name="description"
            htmlType="text"
            placeholder="Optional description"
            value={formData.description}
            onChange={(e) => handleChange("description", e.target.value)}
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Latitude"
            id="edit-location-latitude"
            name="latitude"
            htmlType="text"
            placeholder="e.g. 37.7749"
            value={formData.latitude}
            onChange={(e) => handleChange("latitude", e.target.value)}
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Longitude"
            id="edit-location-longitude"
            name="longitude"
            htmlType="text"
            placeholder="e.g. -122.4194"
            value={formData.longitude}
            onChange={(e) => handleChange("longitude", e.target.value)}
          />
        </form>
      </Modal.Content>
      {/* @ts-expect-error Geist Modal.Action typing is overly strict here */}
      <Modal.Action onClick={() => setOpen(false)} type="secondary">
        Cancel
      </Modal.Action>
      {/* @ts-expect-error Geist Modal.Action typing is overly strict here */}
      <Modal.Action
        loading={loading}
        onClick={() =>
          (
            document.getElementById("edit-location-form") as
              | HTMLFormElement
              | null
          )?.requestSubmit()
        }
      >
        Save
      </Modal.Action>
    </Modal>
  );
}
