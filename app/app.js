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

// Dashboard overview
app.get("/dashboard", async function(req, res) {
    try {
        const categories = await db.query('SELECT id,name,color FROM expense_categories ORDER BY name');
        const expenses = await db.query(`SELECT e.id,e.title,e.amount,e.spent_on,
            c.name AS category,c.color,u.full_name FROM expenses e
            JOIN expense_categories c ON c.id=e.category_id
            JOIN app_users u ON u.id=e.user_id ORDER BY e.spent_on DESC,e.id DESC`);
        const totals = await db.query(`SELECT COALESCE(SUM(amount),0) AS spent,COUNT(*) AS count
            FROM expenses`);
        res.render('dashboard', { title: 'Dashboard | Pennywise', expenses, categories, totals: totals[0] });
    } catch (error) {
        console.error(error);
        res.status(500).send('Dashboard data is unavailable. Check that the database is running and configured.');
    }
});

// Start server on port 3000
app.listen(3000,function(){
    console.log(`Server running at http://127.0.0.1:3000/`);
});
