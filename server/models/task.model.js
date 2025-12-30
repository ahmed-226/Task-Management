const mongoose = require("mongoose");

const stepSchema = new mongoose.Schema({
    title:{
        type:String,
        required:true
    },
    completed:{
        type:Boolean,
        default:false
    }
});

const taskSchema = new mongoose.Schema({
    title:{
        type:String,
        required:true,
        maxlength: 100
    },
    description:{
        type:String,
        maxlength: 255
    },
    status:{
        type:String,
        enum:["todo","pending","in-progress","completed"],
        default:"todo"
    },
    userId:{
        type:mongoose.Schema.Types.ObjectId,
        ref:"User",
        required:true
    },
    steps:[stepSchema]
},{
    timestamps:true 
})

const Task = mongoose.model("Task", taskSchema);

module.exports = Task;