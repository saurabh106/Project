import express, { Express } from "express";
import cors from "cors";
import dotenv from "dotenv";
import { authMiddleware } from "./middlewares/auth";
import routes from "./routes";

dotenv.config();

const app: Express = express();

app.use(cors());
app.use(express.json());

// Public health check
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// Authentication middleware
app.use(authMiddleware);

// API Routes
app.use("/api", routes);

export default app;
