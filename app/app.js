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
        const conditions = ['1=1'];
        const params = [];
        if (req.query.search) {
            conditions.push('(e.title LIKE ? OR c.name LIKE ? OR u.full_name LIKE ?)');
            const search = `%${req.query.search}%`;
            params.push(search, search, search);
        }
        if (req.query.category) { conditions.push('e.category_id = ?'); params.push(req.query.category); }
        if (req.query.from) { conditions.push('e.spent_on >= ?'); params.push(req.query.from); }
        if (req.query.to) { conditions.push('e.spent_on <= ?'); params.push(req.query.to); }
        if (req.query.min) { conditions.push('e.amount >= ?'); params.push(req.query.min); }
        if (req.query.max) { conditions.push('e.amount <= ?'); params.push(req.query.max); }
        const where = conditions.join(' AND ');
        const expenses = await db.query(`SELECT e.id,e.title,e.amount,e.spent_on,
            c.name AS category,c.color,u.full_name FROM expenses e
            JOIN expense_categories c ON c.id=e.category_id
            JOIN app_users u ON u.id=e.user_id WHERE ${where}
            ORDER BY e.spent_on DESC,e.id DESC`, params);
        const totals = await db.query(`SELECT COALESCE(SUM(e.amount),0) AS spent,COUNT(*) AS count
            FROM expenses e JOIN expense_categories c ON c.id=e.category_id
            JOIN app_users u ON u.id=e.user_id WHERE ${where}`, params);
        const budgetRows = await db.query(`SELECT b.amount,c.name,c.color,
            COALESCE(SUM(CASE WHEN e.spent_on >= b.month_start AND e.spent_on < DATE_ADD(b.month_start,INTERVAL 1 MONTH) THEN e.amount ELSE 0 END),0) AS used
            FROM budgets b JOIN expense_categories c ON c.id=b.category_id
            LEFT JOIN expenses e ON e.category_id=c.id GROUP BY b.id,c.name,c.color,b.amount ORDER BY c.name`);
        res.render('dashboard', { title: 'Dashboard | Pennywise', expenses, categories, totals: totals[0], budgets: budgetRows, filters: req.query });
    } catch (error) {
        console.error(error);
        res.status(500).send('Dashboard data is unavailable. Check that the database is running and configured.');
    }
});

// Expense detail page
app.get("/expenses/:id", async function(req, res) {
    try {
        const rows = await db.query(`SELECT e.id,e.title,e.amount,e.spent_on,e.payment_method,e.notes,
            c.name AS category,c.color,u.full_name,u.email FROM expenses e
            JOIN expense_categories c ON c.id=e.category_id
            JOIN app_users u ON u.id=e.user_id WHERE e.id=?`, [req.params.id]);
        if (!rows.length) return res.status(404).render('not-found', { title: 'Expense not found' });
        res.render('detail', { title: `${rows[0].title} | Pennywise`, expense: rows[0] });
    } catch (error) {
        console.error(error);
        res.status(500).send('Expense details are unavailable.');
    }
});

// Start server on port 3000
// Category overview
app.get("/categories", async function(req, res) {
    try {
        const categoryRows = await db.query(`SELECT c.id,c.name,c.color,COUNT(e.id) AS expense_count,
            COALESCE(SUM(e.amount),0) AS total FROM expense_categories c LEFT JOIN expenses e ON e.category_id=c.id
            GROUP BY c.id,c.name,c.color ORDER BY c.name`);
        res.render('categories', { title: 'Categories | Pennywise', categories: categoryRows });
    } catch (error) { console.error(error); res.status(500).send('Categories are unavailable.'); }
});

// Monthly budget overview
app.get("/budgets", async function(req, res) {
    try {
        const budgetRows = await db.query(`SELECT c.name,c.color,b.amount,
            COALESCE(SUM(CASE WHEN e.spent_on >= b.month_start AND e.spent_on < DATE_ADD(b.month_start,INTERVAL 1 MONTH) THEN e.amount ELSE 0 END),0) AS used
            FROM budgets b JOIN expense_categories c ON c.id=b.category_id
            LEFT JOIN expenses e ON e.category_id=c.id GROUP BY b.id,c.name,c.color,b.amount ORDER BY c.name`);
        res.render('budgets', { title: 'Budgets | Pennywise', budgets: budgetRows });
    } catch (error) { console.error(error); res.status(500).send('Budgets are unavailable.'); }
});

// Spending report grouped by category
app.get("/reports", async function(req, res) {
    try {
        const reportRows = await db.query(`SELECT c.name AS category,c.color,COUNT(e.id) AS count,
            COALESCE(SUM(e.amount),0) AS total FROM expense_categories c LEFT JOIN expenses e ON e.category_id=c.id
            GROUP BY c.id,c.name,c.color ORDER BY total DESC`);
        res.render('reports', { title: 'Reports | Pennywise', reports: reportRows });
    } catch (error) { console.error(error); res.status(500).send('Reports are unavailable.'); }
});

app.listen(3000,function(){
    console.log(`Server running at http://127.0.0.1:3000/`);
});
