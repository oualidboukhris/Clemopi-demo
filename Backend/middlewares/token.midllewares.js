require("dotenv").config()
const jwt = require("jsonwebtoken")


const token = (req, res, next) => {
    const token = req.header('Authorization').split(" ")[1];
    if (req.header('Authorization')) {
        if (token === process.env.TOKEN) {
            return next()
        } else {
            return res.json({
                error: true,
                message: 'ERROR 404'
            }).status(404)
        }
    } else {
        return res.status(401).json("You are not authenticated!")
    }
}


// const verifyToken = (req, res, next) => {
//     const token = req.header('Authorization').split(" ")[1];
//     if (req.header('Authorization')) {
//         const token = req.header('Authorization').split(" ")[1];
//         jwt.verify(token, process.env.ACCESS_TOKEN, (err, user) => {

//             if (err) {
//                 return res.status(401).json("You are not authenticated!") 
//             }
//             req.user = user;
//             next();
//         })
//     } else {
//         return res.json({
//             error: true,
//             message: 'ERROR 404'
//         }).status(404)
//     }
// }

const verifyToken = (req, res, next) => {
    try {
        const { cookies, headers } = req;
      
        if (!cookies || !cookies) return res.status(401).json({ message: "Missing token in cookie" })
        const accessToken = cookies._arl;

        if (!headers || !headers["x-xsrf-token"]) return res.status(401).json({ message: 'Missing XSRF token in headers' })
        const xsrfToken = headers["x-xsrf-token"].split("%")[0]
        jwt.verify(accessToken, process.env.ACCESS_TOKEN, (err, user) => {   
                     
            if (err) {
                 return res.status(401).json("You are not authenticated!")
            }
            if(xsrfToken !== user.xsrfToken) return res.status(401).json({ message: 'Bad xsrf token' });
            req.user = user;
            next();
        })
    } catch (error) {
        return res.status(500).json({ message: 'Internal error' });
    }
}


module.exports = { token, verifyToken }