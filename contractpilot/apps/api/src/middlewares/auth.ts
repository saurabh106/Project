import { Request, Response, NextFunction } from "express";
import { verifyToken } from "@clerk/backend";

export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized: Missing or invalid token" });
  }

  const token = authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ error: "Unauthorized: Missing token" });
  }

  try {
    const sessionClaims = await verifyToken(token, {
      secretKey: process.env.CLERK_SECRET_KEY!,
    });
    
    // Attach user info to the request object
    (req as any).auth = {
      userId: sessionClaims.sub,
      claims: sessionClaims,
    };

    next();
  } catch (error) {
    console.error("Clerk token verification failed:", error);
    return res.status(401).json({ error: "Unauthorized: Invalid session" });
  }
};
