import { z, ZodError } from "zod";

export const validateInput = <T>(data: unknown, schema: z.ZodSchema<T>): T => {
  try {
    return schema.parse(data);
  } catch (error) {
    if (error instanceof ZodError) {
      throw new ValidationError("Invalid input", error.issues);
    }
    throw error;
  }
};

export class ValidationError extends Error {
  constructor(
    message: string,
    public details: z.core.$ZodIssue[],
  ) {
    super(message);
    this.name = "ValidationError";
  }
}
