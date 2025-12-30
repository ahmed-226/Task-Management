const Task = require("../models/task.model");

const getAllTasks = async (req, res) => {
    try {
        const tasks = await Task.find({ userId: req.user.userId });
        res.json(tasks);
    } catch (error) {
        res.status(500).json({ message: "Server error" });
    }
}

const getTaskById = async (req, res) => {
    try {
        const task = await Task.findOne({ _id: req.params.id, userId: req.user.userId });
        if (!task) {
            return res.status(404).json({ message: "Task not found" });
        }
        res.json(task);

    }catch (error) {
        res.status(500).json({ message: "Server error" });
    }
}

const createTask = async (req, res) => {
    try {
        const {
            title,
            description,
            status,
            steps
        } = req.body;

        const task = new Task({
            title,
            description,
            status,
            userId : req.user.userId,
            steps
        });
        await task.save();
        res.status(201).json(task);

    }catch (error) {
        res.status(500).json({ message: "Server error" });
    }
}

const updateTask = async (req, res) => {
    try{
        const taskId = req.params.id;
        const updates = req.body;

        const task = await Task.findOneAndUpdate(
            { _id: taskId, userId: req.user.userId },
            updates,
            { new: true }
        )

        if(!task){
            return res.status(404).json({ message: "Task not found" });
        }

        res.json(task);

    } catch (error) {
        res.status(500).json({ message: "Server error" });
    }
}

const deleteTask = async (req, res) => {
    try {
        const taskId = req.params.id;
        const task = await Task.findOneAndDelete({ _id: taskId, userId: req.user.userId });
        if(!task){
            return res.status(404).json({ message: "Task not found" });
        }
        res.json({ message: "Task deleted successfully" });

    } catch (error) {
        res.status(500).json({ message: "Server error" });
    }
}

module.exports = {
    getAllTasks,
    getTaskById,
    createTask,
    updateTask,
    deleteTask
};