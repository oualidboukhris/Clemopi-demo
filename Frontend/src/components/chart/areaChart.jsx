import MuiToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import { styled, createTheme, ThemeProvider } from '@mui/material/styles';
import React, { useEffect } from 'react'
import { Area, CartesianGrid, Tooltip, XAxis, YAxis, AreaChart, Legend, ResponsiveContainer } from 'recharts'
import { BsDownload } from 'react-icons/bs'
import "./areaChart.scss"

// const dataTest = [
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 2,
//     "Register count": 4,
   
//   },
//   {
//     "axisX": "2024-02-07 07:30:43",
//     "Verify count": 3,
//     "Register count": 2,
    
//   },
//   {
//     "axisX": "2024-03-07 07:03:43",
//     "Verify count": 4,
//     "Register count": 2,
    
//   },
//   {
//     "axisX": "2024-04-07 07:03:43",
//     "Verify count": 6,
//     "Register count": 9,
    
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 3,
//     "Register count": 2,
   
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 10,
//     "Register count": 20,
    
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 15,
//     "Register count": 40,
    
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 33,
//     "Register count": 90,
    
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 100,
//     "Register count": 12,
    
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 12,
//     "Register count": 19,
    
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 5,
//     "Register count": 5,
    
//   },
//   {
//     "axisX": "2024-02-07 07:03:43",
//     "Verify count": 3,
//     "Register count": 6,
    
//   }]

const ToggleButton = styled(MuiToggleButton)(({ selectedcolor }) => ({
  '&.Mui-selected, &.Mui-selected:hover': {
    color: 'white',
    backgroundColor: selectedcolor,
  },
  width:80,
  marginLeft:65,
  height:30
}));

const theme = createTheme({
  palette: {
    text: {
      primary: '#00ff00',
    },
  },
});

// const CustomXAxisTick = ({ x, y, payload }) => {
//   // Format the date as needed
//   console.log(payload.value)
//   // const date = payload.value.split(",")[0];
//   // const time = payload.value.split(",")[1];
  
//   // return (
//   //   <g transform={`translate(${x},${y})`}>
//   //     <text x={0} y={0} dy={16} textAnchor="middle" fill="#666">
//   //       <tspan x={0} dy="0.7em">
//   //         {date}
//   //       </tspan>
//   //       <tspan x={0} dy="1em">
//   //         {time}
//   //       </tspan>
//   //     </text>
//   //   </g>
//   // );
// };


function AreaLine(props) {
  const [alignment, setAlignment] = React.useState('day');
  const handleAlignment = (event, newAlignment) => {
    setAlignment(newAlignment);
  };

  return (
    <div className='AreaLine'>
      <div className="areaChart-description">
        <div className="filter-list">
          <ThemeProvider theme={theme}>
            <ToggleButtonGroup
              value={alignment}
              exclusive
              onChange={handleAlignment}
              aria-label="filter"
              size='small'
            >
              <ToggleButton value="day" selectedcolor="#ADC347" >
                day
              </ToggleButton>
              <ToggleButton value="7 day" selectedcolor="#ADC347">
                7 day
              </ToggleButton>
              <ToggleButton value="month" selectedcolor="#ADC347">
                Month
              </ToggleButton>

            </ToggleButtonGroup>
          </ThemeProvider>
        </div>

        <div className="download-chart">
          <BsDownload className='download-icon' />
        </div>

      </div>
      <ResponsiveContainer width="100%" height={350}>
          <AreaChart  data={props.data} >
            <defs>
              <linearGradient id="colorPv" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#191A1A" stopOpacity={0.8} />
                <stop offset="95%" stopColor="#191A1A" stopOpacity={0} />
              </linearGradient>
              <linearGradient id="colorUv" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#ADC347" stopOpacity={0.8} />
                <stop offset="95%" stopColor="#ADC347" stopOpacity={0} />
              </linearGradient>
            </defs>
            <XAxis dataKey="axisX"  />
            <YAxis />
            <CartesianGrid strokeDasharray="3 3" />
            <Tooltip />
            <Legend />
            <Area type="monotone" dataKey="register_count" name='Register count' stroke="#191A1A" fillOpacity={1} fill="url(#colorPv)" />
            <Area type="monotone" dataKey="verify_count" name ='Verify count' stroke="#ADC347" fillOpacity={1} fill="url(#colorUv)" />
          </AreaChart>
      </ResponsiveContainer>
     
    </div>
  )
}

export default AreaLine