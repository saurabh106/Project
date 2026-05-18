import { GoogleGenAI } from "@google/genai";

const getGenAI = () => {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) {
    throw new Error("GEMINI_API_KEY is not defined");
  }
  return new GoogleGenAI({ apiKey });
};

export const analyzeContract = async (text: string) => {
  const ai = getGenAI();
  
  const prompt = `
    You are an expert legal counsel specialized in contract analysis. 
    Analyze the following contract text and provide a detailed risk assessment.
    
    Return the analysis as a single JSON object matching this structure EXACTLY. 
    Do not include any introductory text or markdown formatting.
    
    {
      "contract_type": "string",
      "overall_risk_score": number,
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
            "simple_explanation": "string",
            "business_impact": "string",
            "real_world_example": "string"
          },
          "problem_detected": ["string"],
          "recommendation": {
            "primary_action": "string",
            "secondary_action": "string",
            "priority": "Low" | "Medium" | "High" | "Must Fix"
          },
          "negotiation_language": {
            "email_text": "string",
            "fallback_position": "string"
          },
          "estimated_risk_exposure": "string"
        }
      ],
      "final_recommendation": {
        "decision": "string",
        "must_fix_sections": ["string"],
        "safe_to_accept_sections": ["string"],
        "next_steps": ["string"]
      }
    }

    CONTRACT TEXT:
    ${text.substring(0, 30000)}
  `;

  try {
    const response = await ai.models.generateContent({
      model: "gemini-1.5-flash", 
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
    console.error("Gemini Analysis failed:", error.message);
    throw error;
  }
};

export const chatWithContract = async (text: string, question: string, history: any[] = []) => {
  const ai = getGenAI();

  try {
    const response = await ai.models.generateContent({
      model: "gemini-1.5-flash",
      contents: [
        { role: "user", parts: [{ text: `You are a legal assistant. Use the following contract text as your only source of truth to answer questions. \n\n CONTRACT TEXT: \n ${text.substring(0, 30000)}` }] },
        ...history,
        { role: "user", parts: [{ text: question }] }
      ]
    });

    return response.text || "Sorry, I couldn't generate a response.";
  } catch (error: any) {
    console.error("Gemini Chat failed:", error.message);
    throw error;
  }
};
