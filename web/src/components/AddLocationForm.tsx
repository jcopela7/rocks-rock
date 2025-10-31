import { Input, Modal, Select, Spacer } from "@geist-ui/core";
import { useState } from "react";
import type { CreateLocationInput } from "../api/Locations";
import { useCreateLocation } from "../api_controllers/useLocations";

type Props = {
  open: boolean;
  setOpen: (open: boolean) => void;
  onSuccess?: () => void;
};

export default function AddLocationForm({ open, setOpen, onSuccess }: Props) {
  const { createLocation, loading, error } = useCreateLocation();
  const [formData, setFormData] = useState<Partial<CreateLocationInput>>({
    name: "",
    type: "gym",
    latitude: undefined,
    longitude: undefined,
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.name || !formData.type) {
      return;
    }

    const locationData: CreateLocationInput = {
      id: crypto.randomUUID(), // Generate UUID on client side
      name: formData.name,
      type: formData.type as "gym" | "crag",
      latitude: formData.latitude ? formData.latitude : undefined,
      longitude: formData.longitude ? formData.longitude : undefined,
      createdBy: "00000000-0000-0000-0000-000000000001", // TODO: Replace with actual user ID
    };

    await createLocation(locationData);
    onSuccess?.();

    // Reset form on success
    if (!error) {
      setFormData({
        name: "",
        type: "gym",
        latitude: undefined,
        longitude: undefined,
      });
    }
  };

  const handleInputChange = (
    field: keyof CreateLocationInput,
    value: string | number,
  ) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  return (
    <Modal visible={open} onClose={() => setOpen(false)}>
      <Modal.Title>Add Location</Modal.Title>
      <Modal.Content>
        <form onSubmit={handleSubmit}>
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Name"
            id="location-name"
            name="name"
            htmlType="text"
            placeholder="Enter location name"
            value={formData.name || ""}
            onChange={(e) => handleInputChange("name", e.target.value)}
            required
          />

          <Spacer h={1} />
          {/* @ts-expect-error Geist Select typing is overly strict here */}
          <Select
            placeholder="Select location type"
            value={formData.type}
            onChange={(value) => handleInputChange("type", value as string)}
          >
            <Select.Option value="gym">Gym</Select.Option>
            <Select.Option value="crag">Crag</Select.Option>
          </Select>
        </form>
      </Modal.Content>
      {/* @ts-expect-error Geist Select typing is overly strict here */}

      <Modal.Action onClick={() => setOpen(false)} type="secondary">
        Cancel
      </Modal.Action>
      {/* @ts-expect-error Geist Select typing is overly strict here */}

      <Modal.Action onClick={() => setOpen(false)}>Add Location</Modal.Action>
    </Modal>
  );
}
