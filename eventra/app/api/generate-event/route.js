import { NextResponse } from "next/server";
import { generateWithGemini } from "@/lib/gemini";

export async function POST(req) {
  try {
    const { prompt } = await req.json();

    if (!prompt) {
      return NextResponse.json(
        { error: "Prompt is required" },
        { status: 400 }
      );
    }

    const systemPrompt = `You are an event planning assistant. Generate event details based on the user's description.

CRITICAL: Return ONLY valid JSON with properly escaped strings. No newlines in string values - use spaces instead.

Return this exact JSON structure:
{
  "title": "Event title (catchy and professional, single line)",
  "description": "Detailed event description in a single paragraph. Use spaces instead of line breaks. Make it 2-3 sentences describing what attendees will learn and experience.",
  "category": "One of: tech, music, sports, art, food, business, health, education, gaming, networking, outdoor, community",
  "suggestedCapacity": 50,
  "suggestedTicketType": "free"
}

User's event idea: ${prompt}

Rules:
- Return ONLY the JSON object, no markdown, no explanation
- All string values must be on a single line with no line breaks
- Use spaces instead of \\n or line breaks in description
- Make title catchy and under 80 characters
- Description should be 2-3 sentences, informative, single paragraph
- suggestedTicketType should be either "free" or "paid"
`;

    // ✅ USE YOUR WORKING GEMINI WRAPPER
    const text = await generateWithGemini(systemPrompt);

    // ✅ SAME CLEANING LOGIC (from quiz)
    const cleanedText = text
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    const start = cleanedText.indexOf("{");
    const end = cleanedText.lastIndexOf("}") + 1;

    const eventData = JSON.parse(cleanedText.slice(start, end));

    return NextResponse.json(eventData);
  } catch (error) {
    console.error("Error generating event:", error);

    // ✅ fallback (same style as quiz)
    return NextResponse.json({
      title: "Sample Event",
      description:
        "AI service is currently unavailable. Please try again later.",
      category: "community",
      suggestedCapacity: 50,
      suggestedTicketType: "free",
    });
  }
}