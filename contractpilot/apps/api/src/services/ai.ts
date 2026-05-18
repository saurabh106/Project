import { GoogleGenAI } from "@google/genai";

const getGenAI = () => {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) {
    throw new Error("GEMINI_API_KEY is not defined");
  }
  return new GoogleGenAI({ apiKey });
};

const callGeminiWithRetry = async (ai: any, params: any, maxRetries = 3) => {
  let lastError;
  // Try the primary model first, then fallback to lite if primary is unavailable
  const models = [params.model, "gemini-flash-lite-latest"];
  
  for (const model of models) {
    for (let i = 0; i < maxRetries; i++) {
      try {
        return await ai.models.generateContent({
          ...params,
          model,
        });
      } catch (error: any) {
        lastError = error;
        const errorMessage = error.message || "";
        const isRetryable = errorMessage.includes("503") || 
                          errorMessage.includes("429") || 
                          errorMessage.includes("UNAVAILABLE") || 
                          errorMessage.includes("RESOURCE_EXHAUSTED");

        if (isRetryable) {
          const waitTime = Math.pow(2, i) * 1000;
          console.warn(`Gemini API busy or rate-limited (attempt ${i + 1}/${maxRetries} for ${model}). Retrying in ${waitTime}ms...`);
          await new Promise(resolve => setTimeout(resolve, waitTime));
          continue;
        }
        // Non-retryable error for this model, break inner loop to try next model or fail
        break;
      }
    }
  }
  throw lastError;
};

export const analyzeContract = async (text: string) => {
  const ai = getGenAI();
  
  const prompt = `
    You are an expert legal counsel who excels at explaining complex legal concepts to non-lawyers.
    Analyze the following contract text and provide a detailed risk assessment that anyone can understand.
    
    CRITICAL INSTRUCTION: In the "plain_english" fields, DO NOT use legal jargon. 
    Explain it like you are talking to a business owner who has no legal background.
    Focus on: What does this mean for their money? What does this mean for their time? What is the worst-case scenario?

    Return the analysis as a single JSON object matching this structure EXACTLY. 
    Do not include any introductory text or markdown formatting.
    
    {
      "contract_type": "string",
      "overall_risk_score": number (0-100, where 100 is extreme risk),
      "overall_risk_level": "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
      "summary": {
        "critical_issues": number,
        "high_risk": number,
        "medium_risk": number,
        "low_risk": number
      },
      "clauses": [
        {
          "id": "string",
          "section": "string",
          "title": "string",
          "category": "string",
          "risk_score": number,
          "risk_level": "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
          "is_standard": boolean,
          "original_text": "string",
          "plain_english": {
            "simple_explanation": "A 1-2 sentence explanation of what this clause means in simple, everyday words.",
            "business_impact": "How this affects the business, specifically regarding revenue, liability, or operations.",
            "real_world_example": "A concrete 'What if' scenario (e.g., 'If a fire happens, you won't be covered because...') "
          },
          "problem_detected": ["Specific issues found in the text"],
          "recommendation": {
            "primary_action": "Clear, actionable step (e.g., 'Delete this sentence' or 'Change 30 days to 60 days')",
            "priority": "Low" | "Medium" | "High" | "Must Fix"
          },
          "negotiation_language": {
            "email_text": "A polite but firm sentence the user can copy-paste into an email to the other party to ask for a change.",
            "fallback_position": "A secondary, less ideal but acceptable alternative if the other party says no."
          }
        }
      ],
      "final_recommendation": {
        "decision": "A summary recommendation (e.g., 'Sign with caution after fixing X' or 'Do not sign as is')",
        "must_fix_sections": ["Titles of sections that must be changed"],
        "safe_to_accept_sections": ["Titles of sections that are standard/safe"],
        "next_steps": ["Step 1", "Step 2", "Step 3"]
      }
    }

    CONTRACT TEXT:
    ${text.substring(0, 30000)}
  `;

  try {
    const response = await callGeminiWithRetry(ai, {
      model: "gemini-flash-latest", 
      contents: prompt,
    });

    let jsonString = response.text || "";
    
    if (!jsonString) {
      throw new Error("Empty response from Gemini");
    }

    // Clean up potential markdown formatting
    jsonString = jsonString.replace(/```json\n?/, "").replace(/\n?```/, "").trim();
    
    return JSON.parse(jsonString);
  } catch (error: any) {
    console.error("Gemini Analysis failed after retries:", error.message);
    throw error;
  }
};

export const chatWithContract = async (text: string, question: string, history: any[] = []) => {
  const ai = getGenAI();

  try {
    const response = await callGeminiWithRetry(ai, {
      model: "gemini-flash-latest",
      contents: [
        { role: "user", parts: [{ text: `You are a legal assistant. Use the following contract text as your only source of truth to answer questions. \n\n CONTRACT TEXT: \n ${text.substring(0, 30000)}` }] },
        ...history,
        { role: "user", parts: [{ text: question }] }
      ]
    });

    return response.text || "Sorry, I couldn't generate a response.";
  } catch (error: any) {
    console.error("Gemini Chat failed after retries:", error.message);
    throw error;
  }
};
