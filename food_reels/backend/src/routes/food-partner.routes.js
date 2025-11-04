const express = require("express");
const authMiddleware = require("../middlewares/auth.middleware");
const foodPartnerController = require("../controllers/food-partner.controller");
const router = express.Router();


/* GET /api/foodpartner/:id   */
router.get("/:id",authMiddleware.authUserMiddlewares, foodPartnerController.getFoodPartnerById);

module.exports = router;