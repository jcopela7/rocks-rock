import { Input, Modal, Select } from "@geist-ui/core";
import { useState } from "react";
import type { CreateRouteInputType } from "../api/Routes";
import { useCreateRoute } from "../api_controllers/useRoutes";

type Props = {
  open: boolean;
  setOpen: (open: boolean) => void;
  onSuccess?: () => void;
};

export default function AddRouteForm({ open, setOpen, onSuccess }: Props) {
  const { createRoute, loading, error } = useCreateRoute();
  const [formData, setFormData] = useState<Partial<CreateRouteInputType>>({
    locationId: "",
    name: "",
    discipline: "boulder",
    gradeSystem: "V",
    gradeValue: "",
    gradeRank: 0,
    color: "",
  });

  const handleSubmit = async () => {

    // if (!formData.locationId || !formData.discipline || !formData.gradeSystem || !formData.gradeValue || formData.gradeRank === undefined) {
    //   return;
    // }

    const routeData: CreateRouteInputType = {
      locationId: formData.locationId,
      name: formData.name || undefined,
      discipline: formData.discipline,
      gradeSystem: formData.gradeSystem,
      gradeValue: formData.gradeValue,
      gradeRank: formData.gradeRank,
      color: formData.color || undefined,
    };
    console.log(routeData);
    await createRoute(routeData);
    onSuccess?.();

    // Reset form on success
    if (!error) {
      setFormData({
        locationId: "",
        name: "",
        discipline: "boulder",
        gradeSystem: "V",
        gradeValue: "",
        gradeRank: 0,
        color: "",
      });
    }
  };

  const handleInputChange = (
    field: keyof CreateRouteInputType,
    value: string | number,
  ) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  return (
    <Modal visible={open} onClose={() => setOpen(false)}>
      <Modal.Title>Add Route</Modal.Title>
      <Modal.Content>
        <form onSubmit={handleSubmit}>
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Location ID"
            id="location-id"
            name="locationId"
            htmlType="text"
            placeholder="Enter location ID (UUID)"
            value={formData.locationId || ""}
            onChange={(e) => handleInputChange("locationId", e.target.value)}
            required
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Route Name (Optional)"
            id="route-name"
            name="name"
            htmlType="text"
            placeholder="Enter route name"
            value={formData.name || ""}
            onChange={(e) => handleInputChange("name", e.target.value)}
          />
          {/* @ts-expect-error Geist Select typing is overly strict here */}
          <Select
            placeholder="Select discipline"
            value={formData.discipline}
            onChange={(value) => handleInputChange("discipline", value as string)}
          >
            <Select.Option value="boulder">Boulder</Select.Option>
            <Select.Option value="sport">Sport</Select.Option>
            <Select.Option value="trad">Trad</Select.Option>
          </Select>
          {/* @ts-expect-error Geist Select typing is overly strict here */}
          <Select
            placeholder="Select grade system"
            value={formData.gradeSystem}
            onChange={(value) => handleInputChange("gradeSystem", value as string)}
          >
            <Select.Option value="V">V Scale</Select.Option>
            <Select.Option value="YDS">YDS</Select.Option>
            <Select.Option value="Font">Font</Select.Option>
          </Select>
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Grade Value"
            id="grade-value"
            name="gradeValue"
            htmlType="text"
            placeholder="e.g., V5, 5.12a"
            value={formData.gradeValue || ""}
            onChange={(e) => handleInputChange("gradeValue", e.target.value)}
            required
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Grade Rank"
            id="grade-rank"
            name="gradeRank"
            htmlType="number"
            placeholder="e.g., 5 for V5"
            value={formData.gradeRank || ""}
            onChange={(e) => handleInputChange("gradeRank", parseInt(e.target.value, 10))}
            required
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Color (Optional)"
            id="route-color"
            name="color"
            htmlType="text"
            placeholder="Enter color"
            value={formData.color || ""}
            onChange={(e) => handleInputChange("color", e.target.value)}
          />
        </form>
      </Modal.Content>
      {/* @ts-expect-error Geist Select typing is overly strict here */}
      <Modal.Action onClick={() => setOpen(false)} type="secondary">
        Cancel
      </Modal.Action>
      {/* @ts-expect-error Geist Select typing is overly strict here */}
      <Modal.Action onClick={handleSubmit} loading={loading}>
        Add Route
      </Modal.Action>
    </Modal>
  );
}
