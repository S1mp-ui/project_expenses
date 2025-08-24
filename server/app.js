const express = require('express');
const app = express();
const bcrypt = require('bcrypt');
const con = require('./db');

app.use(express.json()); // รองรับ JSON
app.use(express.urlencoded({ extended: true })); // รองรับ form data ด้วย

// ===== LOGIN =====
app.post('/login',(req,res)=>{
    const {username,password} = req.body;

    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password required' });
    }

    const sql ="SELECT * FROM users WHERE username = ?";
    con.query(sql,[username],(err,result)=>{
        if(err) return res.status(500).json({error:'DB wrong'});
        if(result.length !== 1) return res.status(404).json({error:'Wrong username'});

        bcrypt.compare(password, result[0].password, (err, isMatch) => {
            if(err) return res.status(500).json({error:'Error comparing passwords'});
            
            if(isMatch) {
                res.json({message: "Insert Done", user_id: result[0].id});
            } else {
                res.status(401).json({error:'Invalid password'});
            }
        });
    });
});

// ===== GET EXPENSES =====
app.get('/expenses',(req,res)=>{
    const userId = req.query.user_id;
    if(!userId) return res.status(400).json({ error: 'user_id is required' });

    const sql ="SELECT * FROM expenses WHERE user_id=?";
    con.query(sql,[userId],(err,result)=>{
        if(err) return res.status(500).json({ error: 'Error retrieving expenses' });
        res.json(result);
    });
});






//----get all passwords-----
// http://localhost:3000/password/1234
app.get('/password/:raw', (req, res) => {
    const raw = req.params.raw;
    bcrypt.hash(raw,10,(err,hash) => {
        if(err) {
            return res.status(500).send('Error hashing password');
        }
        res.json( hash );
    });
});

//----get all expenses-----
app.get('/expenses/:user_id', (req, res) => {
    const userId = req.params.user_id;
    const sql ="SELECT * FROM expenses WHERE user_id=?";
    con.query(sql,[userId],(err,result) => {
        if(err) return res.status(500).send('Error retrieving expenses');
        res.json(result);  
    });
});;    


//get today expenses
app.get('/expenses/today/:user_id', (req, res) => {
    const userId = req.params.user_id;
    const today = new Date().toISOString().split('T')[0]; // Get today's date in YYYY-MM-DD format
    const sql = "SELECT * FROM expenses WHERE user_id=? AND DATE(date) = ?";
    
    con.query(sql, [userId, today], (err, result) => {
        if(err) return res.status(500).send('Error retrieving today\'s expenses');
        res.json(result);
    });
});

 
//Search expenses 




















//ADD EXPENSES
app.post






















//DELETE EXPENSES
app.delete


















app.listen(3000,() =>  {
    console.log("server is run");
});