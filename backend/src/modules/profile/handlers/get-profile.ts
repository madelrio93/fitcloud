import type { APIGatewayProxyEvent } from "aws-lambda";
import { response } from "../../../shared/response";

export const handleGetUser = async (event: APIGatewayProxyEvent) => {
  try {
    return response(200, {
      data: JSON.stringify({
        data: "This is a placeholder response for the get profile endpoint.",
      }),
      message: "Get profile endpoint is under construction",
    });
  } catch (error) {
    console.error("Error getting profile:", error);
    return response(500, { error: "Internal server error" });
  }
};
