import React from 'react'
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import './barChart.scss'
const data = [
    {
        "name": "Jan",
        "Verify count": 4000,
        "Register count": 2400,
        
    },
    {
        "name": "Feb",
        "Verify count": 3000,
        "Register count": 1398,
        
    },
    {
        "name": "Mar",
        "Verify count": 2000,
        "Register count": 9800,
       
    },
    {
        "name": "Apr",
        "Verify count": 2780,
        "Register count": 3908,
       
    },
    {
        "name": "May",
        "Verify count": 1890,
        "Register count": 4800,
      
    },
    {
        "name": "Jun",
        "Verify count": 1890,
        "Register count": 3908,
       
    },
    {
        "name": "Jui",
        "Verify count": 1890,
        "Register count": 3908,
      
    },
    {
        "name": "Aug",
        "Verify count": 1890,
        "Register count": 4800,
       
    },


    {
        "name": "Sep",
        "Verify count": 1890,
        "Register count": 4800,
       
    },
    {
        "name": "Oct",
        "Verify count": 1890,
        "Register count": 4800,
       
    },
    {
        "name": "Nov",
        "Verify count": 2780,
        "Register count": 3908,
       
    },
    {
        "name": "Dec",
        "Verify count": 1890,
        "Register count": 4800,
       
    },]
function Barchart(props) {
    return (
        <div className='Barchart'>
            <ResponsiveContainer width="100%" height={400}>
                <BarChart data={props.data}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="axisX" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    
                    <Bar dataKey="register_count" name='Register count' fill="#191A1A" />
                    <Bar dataKey="verify_count" name ='Verify count' fill="#ADC347" />
                </BarChart>
            </ResponsiveContainer>

        </div>
    )
}

export default Barchart