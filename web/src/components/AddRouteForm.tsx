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
    description: "",
    discipline: "boulder",
    gradeSystem: "V",
    gradeValue: "",
    gradeRank: 0,
    starRating: undefined,
  });

  const handleSubmit = async () => {
    if (
      !formData.locationId ||
      !formData.discipline ||
      !formData.gradeSystem ||
      formData.gradeValue === undefined ||
      formData.gradeValue === "" ||
      formData.gradeRank === undefined
    ) {
      return;
    }

    const routeData: CreateRouteInputType = {
      locationId: formData.locationId,
      name: formData.name || undefined,
      description: formData.description || undefined,
      discipline: formData.discipline,
      gradeSystem: formData.gradeSystem,
      gradeValue: formData.gradeValue,
      gradeRank: formData.gradeRank,

      starRating:
        formData.starRating != null && formData.starRating >= 1
          ? formData.starRating
          : undefined,
    };
    await createRoute(routeData);
    onSuccess?.();

    // Reset form on success
    if (!error) {
      setFormData({
        locationId: "",
        name: "",
        description: "",
        discipline: "boulder",
        gradeSystem: "V",
        gradeValue: "",
        gradeRank: 0,
        starRating: undefined,
      });
    }
  };

  const handleInputChange = (
    field: keyof CreateRouteInputType,
    value: string | number | undefined,
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
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Description (Optional)"
            id="route-description"
            name="description"
            htmlType="text"
            placeholder="Enter route description"
            value={formData.description || ""}
            onChange={(e) => handleInputChange("description", e.target.value)}
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
            value={String(formData.gradeRank ?? "")}
            onChange={(e) => {
              const parsed = parseInt(e.target.value, 10);
              handleInputChange("gradeRank", isNaN(parsed) ? 0 : parsed);
            }}
            required
          />
          {/* @ts-expect-error Geist Select typing is overly strict here */}
          <Select
            placeholder="Star rating (optional)"
            value={
              formData.starRating != null && formData.starRating >= 1
                ? String(formData.starRating)
                : ""
            }
            onChange={(value) =>
              handleInputChange(
                "starRating",
                value === "" ? undefined : parseInt(value as string, 10),
              )
            }
          >
            <Select.Option value="">None</Select.Option>
            <Select.Option value="1">★ 1</Select.Option>
            <Select.Option value="2">★★ 2</Select.Option>
            <Select.Option value="3">★★★ 3</Select.Option>
            <Select.Option value="4">★★★★ 4</Select.Option>
            <Select.Option value="5">★★★★★ 5</Select.Option>
          </Select>
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
