const foodModel = require("../models/food.model");
const storageService = require("../services/storage.service");
const { v4: uuidv4 } = require("uuid");
const likeModel = require("../models/like.model");
const saveModel = require("../models/save.model");

// In this the doufile missing and validator (express validator) is missing
async function createFood(req, res) {
  console.log("BODY:", req.body);
  console.log("FILE:", req.file);
  const fileUploadResult = await storageService.uploadFile(
    req.file.buffer,
    uuidv4()
  );

  const foodItem = await foodModel.create({
    name: req.body.name,
    description: req.body.description,
    video: fileUploadResult.url,
    foodPartner: req.foodPartner._id,
  });

  res.status(201).json({
    message: "Food item created successfully",
    food: foodItem,
  });
}

async function getFoodItems(req, res) {
  const foodItems = await foodModel.find({});
  res.status(200).json({
    message: "Food items fetched successfully",
    foodItems: foodItems,
  });
}

async function likeFood(req, res) {
  const { foodId } = req.body;

  const user = req.user;

  const isAlreadyLiked = await likeModel.findOne({
    user: user._id,
    food: foodId,
  });
  if (isAlreadyLiked) {
    await likeModel.deleteOne({ user: user._id, food: foodId });
    await foodModel.findByIdAndUpdate(foodId, { $inc: { likeCount: -1 } });
    return res.status(200).json({ message: "Food item unliked successfully" });
  }
  const like = await likeModel.create({
    user: user._id,
    food: foodId,
  });
  await foodModel.findByIdAndUpdate(foodId, { $inc: { likeCount: 1 } });
  res.status(201).json({ message: "Food item liked successfully", like });
}

async function saveFood(req, res) {
  const { foodId } = req.body;

  const user = req.user;

  const isAlreadySaved = await saveModel.findOne({
    user: user._id,
    food: foodId,
  });
  if (isAlreadySaved) {
    await saveModel.deleteOne({ user: user._id, food: foodId });

    await foodModel.findByIdAndUpdate(foodId, { $inc: { savesCount: -1 } });


    return res.status(200).json({ message: "Food item unsaved successfully" });
  }
  const save = await saveModel.create({
    user: user._id,
    food: foodId,
  });

  await foodModel.findByIdAndUpdate(foodId, { $inc: { savesCount: 1 } });

  res.status(201).json({ message: "Food item saved successfully", save });
}

async function getSavedFood(req, res) {
  const user = req.user;

  const savedFoods = await saveModel.find({ user: user._id }).populate('food');

  if (!savedFoods) {
    return res.status(404).json({ message: "No saved food items found" });
  }

  res.status(200).json({ message: "Saved food items fetched successfully", savedFoods });
}


module.exports = { createFood, getFoodItems, likeFood, saveFood , getSavedFood};
