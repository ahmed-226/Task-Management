const User = require("../models/user.model");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const login = async (req, res) => {
    try {
        const {email, password} = req.body;
        const user = await User.findOne({email});
        if(!user){
            return res.status(400).json({ message: "Invalid email or password" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if(!isMatch){
            return res.status(400).json({ message: "Invalid email or password" });
        }

        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: "1h" }
        )
        res.json({ token });

    }catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ message: "Server error" });
    }
}

const register = async (req, res) => {
    try{
        const {
        username,
        email,
        password
    } = req.body;

    const isExist = await User.findOne({email});
    if(isExist){
        return  res.status(400).json({message:"User already exists"});
    }

    const user = new User({
        username,
        email,
        password
    })
    await user.save();

    const token = jwt.sign(
        { userId: user._id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
    )
    res.status(201).json({token, message:"User registered successfully"});

}catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({message:"Server error"});

}}

module.exports = {
    login,
    register
};