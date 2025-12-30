const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv")
const cors = require("cors");


const app = express();

// Enable CORS for client on port 3000
app.use(cors({
	origin: 'http://localhost:3000',
	credentials: true
}));

app.use(express.json());


const userRoutes = require("./routes/user.route");
const taskRoutes = require("./routes/task.route");


dotenv.config();

const PORT = process.env.PORT || 4000;



app.get("/", (req, res) => {
	res.send("hello world1");
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