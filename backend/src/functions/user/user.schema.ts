import z from "zod";

export const UserProfileSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  password_hash: z.string(),
  role: z.enum(["user", "admin"]),
  created_at: z.string(),
  updated_at: z.string(),
  profile: z.object({
    username: z.string(),
    display_name: z.string(),
    email: z.string().email(),
    bio: z.string(),
    avatar_url: z.string(),
    joined_at: z.string(),
  }),
  settings: z.object({
    unit_system: z.enum(["metric", "imperial"]),
    privacy: z.enum(["public", "private", "friends"]),
    target_metrics: z.array(z.string()),
  }),
  static_metrics: z.object({
    birth_date: z.string(),
    gender: z.enum(["male", "female", "other", "prefer_not_to_say"]),
    height_cm: z.number(),
  }),
  current_goals: z.object({
    target_weight_kg: z.number().optional(),
    target_body_fat_percentage: z.number().optional(),
    daily_step_goal: z.number().optional(),
  }),
  metric_history: z.array(
    z.object({
      timestamp: z.string(),
      type: z.enum(["weight", "body_fat", "circumference"]),
    }),
  ),
  progress_photos: z.array(
    z.object({
      url: z.string(),
      timestamp: z.string(),
    }),
  ),
});

export type UserProfile = z.infer<typeof UserProfileSchema>;
