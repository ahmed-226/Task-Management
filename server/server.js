const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv")
const cors = require("cors");

dotenv.config();

const app = express();

const allowedOrigins = process.env.ALLOWED_ORIGINS 
    ? process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim())
    : ['http://localhost:3000'];

app.use(cors({
    origin: function (origin, callback) {
        // Allow requests with no origin (mobile apps, Postman, curl, etc.)
        if (!origin) return callback(null, true);
        
        if (allowedOrigins.indexOf(origin) !== -1 || allowedOrigins.includes('*')) {
            callback(null, true);
        } else {
            callback(new Error(`CORS policy: Origin ${origin} is not allowed`));
        }
    },
    credentials: true
}));

app.use(express.json());

const userRoutes = require("./routes/user.route");
const taskRoutes = require("./routes/task.route");

const PORT = process.env.PORT || 4000;

app.get("/", (req, res) => {
    res.send("Task Management API");
})

app.use("/api/users", userRoutes);
app.use("/api/tasks", taskRoutes);

mongoose.connect(process.env.MONGODB_URI)
    .then(() => {
        console.log("Connected to MongoDB");
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch((error) => {
        console.error("Error connecting to MongoDB:", error);
    });