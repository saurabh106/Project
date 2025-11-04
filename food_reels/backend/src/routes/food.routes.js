const express = require("express");
const router = express.Router();
const authMiddleware = require("../middlewares/auth.middleware");
const foodController = require("../controllers/food.controller");
const multer = require("multer");
const upload = multer({
  storage: multer.memoryStorage(),
});

/* POST /api/food/   [protected]*/
router.post(
  "/",
  authMiddleware.authFoodPartnerMiddleware,
  upload.single("video"),
  foodController.createFood
);

/* GET /api/food/   [protected]*/
router.get("/",authMiddleware.authUserMiddlewares, foodController.likeFood);

router.post(
  "/like",
  authMiddleware.authUserMiddlewares,
  foodController.likeFood
);

router.post("/save", authMiddleware.authUserMiddlewares, foodController.saveFood);

router.get("/save", authMiddleware.authUserMiddlewares, foodController.getSavedFood);



module.exports = router;
