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
    const response = await (ai as any).models.list();
    
    console.log("Available models:");
    // Try both for-await-of and standard iteration
    try {
      for await (const m of response) {
        console.log(`- ${m.name}`);
      }
    } catch (e) {
      console.log("Not an async iterator, trying standard array...");
      const models = Array.isArray(response) ? response : (response.models || []);
      models.forEach((m: any) => console.log(`- ${m.name}`));
    }
  } catch (error: any) {
    console.error("Error listing models:", error.message);
    if (error.response) {
       console.error("Response data:", error.response.data);
    }
  }
}

listModels();
