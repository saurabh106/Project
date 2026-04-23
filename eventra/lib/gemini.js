import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

let cachedModels = [];

async function getModels() {
  if (cachedModels.length) return cachedModels;

  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models?key=${process.env.GEMINI_API_KEY}`
    );
    const data = await res.json();

    cachedModels = data.models
      .filter(
        (m) =>
          m.name.includes("gemini") &&
          m.supportedGenerationMethods?.includes("generateContent") &&
          !m.name.includes("embedding")
      )
      .map((m) => m.name.split("/").pop());

    console.log("Available models:", cachedModels);

    return cachedModels;
  } catch (err) {
    console.error("Model fetch failed:", err);

    // fallback list
    return ["gemini-1.5-flash"];
  }
}

export async function generateWithGemini(prompt, retries = 2) {
  const models = await getModels();

  for (const modelName of models) {
    try {
      const model = genAI.getGenerativeModel({ model: modelName });

      const result = await model.generateContent(prompt);
      return result.response.text();
    } catch (error) {
      console.error(`Model ${modelName} failed:`, error.status);

      // 🔁 Retry for overload or rate limit
      if ((error.status === 503 || error.status === 429) && retries > 0) {
        await new Promise((res) => setTimeout(res, 2000));
        return generateWithGemini(prompt, retries - 1);
      }

      // ❌ try next model
      continue;
    }
  }

  // ❌ all models failed
  throw new Error("All Gemini models failed");
}