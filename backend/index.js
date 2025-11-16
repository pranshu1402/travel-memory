const express = require('express')
const cors = require('cors')
require('dotenv').config()

const app = express()
PORT = process.env.PORT
const conn = require('./conn')
app.use(express.json())
app.use(cors())

// Prometheus metrics middleware
const { metricsMiddleware, metricsHandler } = require('./middleware/prometheus')
app.use(metricsMiddleware)

const tripRoutes = require('./routes/trip.routes')

app.use('/trip', tripRoutes) // http://localhost:3001/trip --> POST/GET/GET by ID

app.get('/hello', (req,res)=>{
    res.send('Hello World!')
})

// Prometheus metrics endpoint
app.get('/metrics', metricsHandler)

app.listen(PORT, ()=>{
    console.log(`Server started at http://localhost:${PORT}`)
})