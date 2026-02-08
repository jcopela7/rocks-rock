import { Input, Modal, Select, Text } from "@geist-ui/core";
import { useEffect, useState } from "react";
import type {
  RouteType,
  UpdateRouteInputType,
} from "../api/Routes";
import { useUpdateRoute } from "../api_controllers/useRoutes";

type Props = {
  route: RouteType | null;
  open: boolean;
  setOpen: (open: boolean) => void;
  onSuccess?: () => void;
};

export default function EditRouteForm({
  route,
  open,
  setOpen,
  onSuccess,
}: Props) {
  const { updateRoute, loading, error } = useUpdateRoute();
  const [formData, setFormData] = useState<{
    locationId: string;
    name: string;
    description: string;
    discipline: string;
    gradeSystem: string;
    gradeValue: string;
    gradeRank: number;
    starRating: number | null;
  }>({
    locationId: "",
    name: "",
    description: "",
    discipline: "boulder",
    gradeSystem: "V",
    gradeValue: "",
    gradeRank: 0,
    starRating: null,
  });

  useEffect(() => {
    if (route) {
      setFormData({
        locationId: route.locationId ?? "",
        name: route.name ?? "",
        description: route.description ?? "",
        discipline: route.discipline ?? "boulder",
        gradeSystem: route.gradeSystem ?? "V",
        gradeValue: route.gradeValue ?? "",
        gradeRank: route.gradeRank ?? 0,
        starRating: route.starRating ?? null,
      });
    }
  }, [route]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!route) return;
    if (
      !formData.locationId ||
      !formData.discipline ||
      !formData.gradeSystem ||
      formData.gradeValue === "" ||
      formData.gradeRank === undefined
    ) {
      return;
    }

    const payload: UpdateRouteInputType = {
      locationId: formData.locationId,
      name: formData.name || undefined,
      description: formData.description || null,
      discipline: formData.discipline as "boulder" | "sport" | "trad",
      gradeSystem: formData.gradeSystem as "V" | "YDS" | "Font",
      gradeValue: formData.gradeValue,
      gradeRank: formData.gradeRank,
      starRating:
        formData.starRating != null && formData.starRating >= 1
          ? formData.starRating
          : null,
    };

    try {
      await updateRoute(route.id, payload);
      setOpen(false);
      onSuccess?.();
    } catch {
      // Error surfaced by useUpdateRoute
    }
  };

  const handleChange = (
    field: keyof typeof formData,
    value: string | number | null,
  ) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  if (!route) return null;

  return (
    <Modal visible={open} onClose={() => setOpen(false)}>
      <Modal.Title>Edit Route</Modal.Title>
      <Modal.Content>
        {error && (
          <Text type="error" small style={{ marginBottom: 8 }}>
            {error}
          </Text>
        )}
        <form id="edit-route-form" onSubmit={handleSubmit}>
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Location ID"
            id="edit-route-location-id"
            name="locationId"
            htmlType="text"
            placeholder="Enter location ID (UUID)"
            value={formData.locationId}
            onChange={(e) => handleChange("locationId", e.target.value)}
            required
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Route Name (Optional)"
            id="edit-route-name"
            name="name"
            htmlType="text"
            placeholder="Enter route name"
            value={formData.name}
            onChange={(e) => handleChange("name", e.target.value)}
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Description (Optional)"
            id="edit-route-description"
            name="description"
            htmlType="text"
            placeholder="Enter route description"
            value={formData.description}
            onChange={(e) => handleChange("description", e.target.value)}
          />
          {/* @ts-expect-error Geist Select typing is overly strict here */}
          <Select
            placeholder="Select discipline"
            value={formData.discipline}
            onChange={(value) => handleChange("discipline", value as string)}
          >
            <Select.Option value="boulder">Boulder</Select.Option>
            <Select.Option value="sport">Sport</Select.Option>
            <Select.Option value="trad">Trad</Select.Option>
          </Select>
          {/* @ts-expect-error Geist Select typing is overly strict here */}
          <Select
            placeholder="Select grade system"
            value={formData.gradeSystem}
            onChange={(value) => handleChange("gradeSystem", value as string)}
          >
            <Select.Option value="V">V Scale</Select.Option>
            <Select.Option value="YDS">YDS</Select.Option>
            <Select.Option value="Font">Font</Select.Option>
          </Select>
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Grade Value"
            id="edit-route-grade-value"
            name="gradeValue"
            htmlType="text"
            placeholder="e.g., V5, 5.12a"
            value={formData.gradeValue}
            onChange={(e) => handleChange("gradeValue", e.target.value)}
            required
          />
          {/* @ts-expect-error Geist Input typing is overly strict here */}
          <Input
            label="Grade Rank"
            id="edit-route-grade-rank"
            name="gradeRank"
            htmlType="number"
            placeholder="e.g., 5 for V5"
            value={String(formData.gradeRank)}
            onChange={(e) => {
              const parsed = parseInt(e.target.value, 10);
              handleChange("gradeRank", isNaN(parsed) ? 0 : parsed);
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
              handleChange(
                "starRating",
                value === "" ? null : parseInt(value as string, 10),
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
      {/* @ts-expect-error Geist Modal.Action typing is overly strict here */}
      <Modal.Action onClick={() => setOpen(false)} type="secondary">
        Cancel
      </Modal.Action>
      {/* @ts-expect-error Geist Modal.Action typing is overly strict here */}
      <Modal.Action
        loading={loading}
        onClick={() =>
          (
            document.getElementById("edit-route-form") as
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
