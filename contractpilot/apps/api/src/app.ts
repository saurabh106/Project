import dotenv from "dotenv";
dotenv.config();

import express, { Express } from "express";
import cors from "cors";
import { authMiddleware } from "./middlewares/auth";
import routes from "./routes";

const app: Express = express();

app.use(cors({
  origin: "http://localhost:3000",
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Public health check
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// Authentication middleware
app.use(authMiddleware);

// API Routes
app.use("/api", routes);

export default app;
