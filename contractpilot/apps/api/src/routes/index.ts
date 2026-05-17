import { Router } from "express";

const router: Router = Router();

router.get("/user/profile", (req, res) => {
  const auth = (req as any).auth;
  res.json({
    message: "Success",
    userId: auth.userId,
    details: "This is a protected route",
  });
});

export default router;
