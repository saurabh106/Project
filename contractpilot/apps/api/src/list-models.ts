import dotenv from "dotenv";
dotenv.config();
import { GoogleGenAI } from "@google/genai";

async function listModels() {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) {
    console.error("GEMINI_API_KEY is not defined");
    return;
  }
  
  const ai = new GoogleGenAI({ apiKey });
  
  try {
    console.log("Fetching models...");
    // The @google/genai library might have a different method for listing models
    // Let's try the common patterns
    const response = await (ai as any).models.list();
    console.log("Available models:");
    response.models.forEach((m: any) => {
      console.log(`- ${m.name} (Supports: ${m.supportedGenerationMethods.join(", ")})`);
    });
  } catch (error: any) {
    console.error("Error listing models:", error.message);
    if (error.response) {
       console.error("Response data:", error.response.data);
    }
  }
}

listModels();
