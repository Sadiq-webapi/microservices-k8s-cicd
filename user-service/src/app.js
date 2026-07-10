const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    service: "user-service",
    status: "running"
  });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "UP"
  });
});

module.exports = app;