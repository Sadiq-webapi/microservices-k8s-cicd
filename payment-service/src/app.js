const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
    res.json({
        service: "payment-service",
        status: "running"
    });
});

app.get("/health", (req, res) => {
    res.json({
        status: "UP"
    });
});

module.exports = app;