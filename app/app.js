// Import express.js
const express = require("express");

// Create express app
var app = express();

// Configure Pug templates
app.set("views", "app/views");
app.set("view engine", "pug");

// Add static files location
app.use(express.static("static"));

// Get the functions in the db.js file to use
const db = require('./services/db');

// Create a route for root - /
app.get("/", function(req, res) {
    res.render("index", { title: "Pennywise | Spend with clarity" });
});

// Sign in and account registration screens
app.get("/login", function(req, res) {
    res.render("login", { title: "Sign in | Pennywise" });
});
app.get("/register", function(req, res) {
    res.render("register", { title: "Create account | Pennywise" });
});

// Start server on port 3000
app.listen(3000,function(){
    console.log(`Server running at http://127.0.0.1:3000/`);
});
