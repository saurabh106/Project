import { Router, Request, Response } from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
const pdf = require("pdf-parse");
import { prisma } from "@repo/db";
import { analyzeContract, chatWithContract } from "../services/ai";

const router: Router = Router();

// Configure storage for PDF uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, "../../uploads");
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + "-" + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype === "application/pdf") {
      cb(null, true);
    } else {
      cb(new Error("Only PDF files are allowed"));
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
});

router.post("/upload", upload.single("contract"), async (req: Request, res: Response) => {
  console.log("Upload request received");
  try {
    const auth = (req as any).auth;
    const file = req.file;

    if (!file) {
      console.error("No file found in request");
      return res.status(400).json({ error: "No file uploaded" });
    }

    console.log(`Uploading file: ${file.originalname} for user: ${auth.userId}`);

    // Read PDF and extract text
    let extractedText = "";
    try {
      const dataBuffer = fs.readFileSync(file.path);
      const pdfData = await pdf(dataBuffer);
      extractedText = pdfData.text;
      console.log(`Extracted ${extractedText.length} characters from PDF`);
    } catch (pdfError) {
      console.error("PDF extraction failed:", pdfError);
      // We still proceed but with empty text, or handle as error
    }

    // Ensure user exists in our DB (sync with Clerk)
    try {
      await prisma.user.upsert({
        where: { clerkId: auth.userId },
        update: {},
        create: {
          clerkId: auth.userId,
          email: auth.claims.email || `${auth.userId}@example.com`,
          firstName: auth.claims.first_name || "",
          lastName: auth.claims.last_name || "",
        },
      });
    } catch (dbError) {
      console.error("User sync error:", dbError);
    }

    // Save contract record in DB with extracted text
    const contract = await prisma.contract.create({
      data: {
        name: file.originalname,
        fileUrl: file.path, 
        extractedText: extractedText,
        userId: auth.userId,
        status: "PENDING",
      },
    });

    console.log("Contract saved to DB with extracted text:", contract.id);

    res.status(201).json({
      message: "Contract uploaded and text extracted successfully",
      contract: {
        id: contract.id,
        name: contract.name,
        status: contract.status,
      },
    });
  } catch (error) {
    console.error("Upload process failed:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.get("/my-contracts", async (req: Request, res: Response) => {
  try {
    const auth = (req as any).auth;
    const contracts = await prisma.contract.findMany({
      where: { userId: auth.userId },
      orderBy: { createdAt: "desc" },
    });
    res.json(contracts);
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/:id/analyze", async (req: Request, res: Response) => {
  const id = req.params.id as string;
  console.log(`Received analysis request for contract ID: ${id}`);
  try {
    const auth = (req as any).auth;

    const contract = await prisma.contract.findUnique({
      where: { id, userId: auth.userId },
    });

    if (!contract) {
      console.error(`Contract not found: ${id} for user: ${auth.userId}`);
      return res.status(404).json({ error: "Contract not found" });
    }

    if (!contract.extractedText) {
      console.error(`No extracted text for contract: ${id}`);
      return res.status(400).json({ error: "Contract has no extracted text. Please re-upload." });
    }

    console.log(`Analyzing contract: ${contract.name} (${contract.extractedText.length} chars)`);

    // Call AI Service
    const analysis = await analyzeContract(contract.extractedText);
    console.log("AI Analysis completed successfully");

    // Update contract in DB
    const updatedContract = await prisma.contract.update({
      where: { id },
      data: {
        analysis: analysis as any,
        status: "REVIEW",
      },
    });

    console.log("Contract updated in DB with analysis result");

    res.json({
      message: "Analysis completed",
      analysis: updatedContract.analysis,
    });
  } catch (error: any) {
    console.error("Analysis route error:", error);
    res.status(500).json({ error: error.message || "Internal server error" });
  }
});

router.post("/:id/chat", async (req: Request, res: Response) => {
  const id = req.params.id as string;
  try {
    const auth = (req as any).auth;
    const { message, history } = req.body;

    const contract = await prisma.contract.findUnique({
      where: { id, userId: auth.userId },
    });

    if (!contract || !contract.extractedText) {
      return res.status(404).json({ error: "Contract not found" });
    }

    const answer = await chatWithContract(contract.extractedText, message, history);

    res.json({ answer });
  } catch (error: any) {
    console.error("Chat route error:", error);
    res.status(500).json({ error: error.message || "Internal server error" });
  }
});

router.delete("/:id", async (req: Request, res: Response) => {
  const id = req.params.id as string;
  try {
    const auth = (req as any).auth;

    const contract = await prisma.contract.findUnique({
      where: { id, userId: auth.userId },
    });

    if (!contract) {
      return res.status(404).json({ error: "Contract not found" });
    }

    // Remove file from disk
    if (fs.existsSync(contract.fileUrl)) {
      fs.unlinkSync(contract.fileUrl);
    }

    await prisma.contract.delete({
      where: { id },
    });

    res.json({ message: "Contract deleted successfully" });
  } catch (error) {
    console.error("Delete error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
