import { Avatar } from '@mui/material';
import React from 'react'
import { PieChart, Pie, Cell, Legend } from "recharts";
import "./pieChart.scss"

// const data = [
//   { name: "Verify count", value: 120},
//   { name: "Register count", value: 200 },
// ];

const COLORS = ["#ADC347", "#191A1A"];
const RADIAN = Math.PI / 180;
const renderCustomizedLabel = ({
  cx,
  cy,
  midAngle,
  innerRadius,
  outerRadius,
  percent,
  index
}) => {
  const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
  const x = cx + radius * Math.cos(-midAngle * RADIAN);
  const y = cy + radius * Math.sin(-midAngle * RADIAN);
  return (
    <text
      x={x}
      y={y}
      fill="white"
      textAnchor={x > cx ? "start" : "end"}
      dominantBaseline="central"
    >
      {`${(percent * 100).toFixed(0)}%`}
    </text>
  );
};

function Piechart(props) {  
  return (
    <div className='Piechart'>
      <div className="description-pichart">
        <div className="description-item">
          {props.data.map((data)=> {
            return (
               <div className="description-content" key={data.name}>
               <span className='description-title'>{data.name}</span>
               <Avatar sx={{ bgcolor: "#ADC347", width: 20, height: 20 }} className="avatar" >
                 <span>{data.value}</span>
               </Avatar>
             </div>)
          })}  
        </div>
     
      </div>

      <PieChart width={300} height={260}>
        <Pie
          data={props.data}
          cx={150}
          cy={110}
          labelLine={false}
          label={renderCustomizedLabel}
          outerRadius={100}
          dataKey="value"
        >
          {props.data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Legend />
      </PieChart>

    </div>
  )
}

export default Piechart