import React, { useState } from 'react'
import MasterPage from '../../components/masterPage/masterPage'
import './orderList.scss'
import { SlRefresh } from 'react-icons/sl'
import { createTheme, Pagination, Slider } from '@mui/material'
import { ThemeProvider } from '@emotion/react'
import 'react-date-range/dist/styles.css';
import 'react-date-range/dist/theme/default.css';
import { DateRange } from 'react-date-range'
import Moment from 'moment';
import { BsFillCalendarFill } from 'react-icons/bs'
import { useRef } from 'react'
import { Link } from 'react-router-dom'





function createData(id, qrCode, account, minutes, amount, meters, beginTime, finishTime) {
    return {
        id,
        qrCode,
        account,
        minutes,
        amount,
        meters,
        beginTime,
        finishTime,
    };
}

const rows = [
    createData(1, "QR554824", "oualidha@gmail.com", "18", "1000","1500" ,"16:25:30 12/12/2022", "16:25:30 12/12/2022"),
    createData(2, "QR554824", "salmadha@gmail.com", "2500", "-18856","2000", "16:25:30 12/12/2022", "16:25:30 12/12/2022"),
    createData(3, "QR554824", "lkhadija@gmail.com", "180", "552","3000", "16:25:30 12/12/2022", "16:25:30 12/12/2022"),
    createData(4, "QR554824", "samir@gmail.com", "166", "17356", "3500","16:25:30 12/12/2022", "16:25:30 12/12/2022"),
    createData(5, "QR554824", "sawsan@gmail.com", "22", "12356","2000" ,"16:25:30 12/12/2022", "16:25:30 12/12/2022"),
    createData(6, "QR554824", "driss@gmail.com", "888", "1576", "1700","16:25:30 12/12/2022", "16:25:30 12/12/2022"),
   
];

const headCells = [
    {
        id: 'qrCode',
        label: 'QR code',
    },
    {
        id: 'account',
        label: 'Account',
    },
    {
        id: 'minutes',
        label: 'Minutes',
    },
    {
        id: 'amount',
        label: 'Amount',
    },
    {
        id: 'meters',
        label: 'Meters',
    },
    {
        id: 'beginTime',
        label: 'Begin time',
    },
    {
        id: 'finishTime',
        label: 'Finish time',
    },
    {
        id: 'picture',
        label: 'Picture',
    },

];
const theme = createTheme({
    palette: {
        primary: {
            main: '#ADC347',
        },

    },
});







function OrderList() {
    const [page, setPage] = useState(1);
    const [openRegisterDate, setOpenRegisterDate] = useState(false);
    const refOne = useRef(null);
    const [value, setValue] = React.useState([0, 100]);
    const handleChange = (event, newValue) => {
        setValue(newValue);
    };
    const [state, setState] = useState([
        {
            startDate: new Date(),
            endDate: new Date(),
            key: 'selection'
        }
    ]);

    return (
        <MasterPage>
            <div className='OrderList'>
                <div className="header-order">
                    <div className="title-order">Kickscooter order list (229 records)</div>
                    <div className='buttons-order'>
                        <button className='btn-refresh'>
                            <span className='icon-btn-refresh'><SlRefresh /></span>
                            <span className='title-btn-refresh'>Refresh</span>
                        </button>
                    </div>
                </div>

                <div className="filter-order">
                    <div className="filter">
                        <label htmlFor="userId">User ID</label>
                        <input type="text" name="userId" id="userId" />
                    </div>
                    <div className="filter">
                        <label htmlFor="kickscooterId">Kickscooter</label>
                        <input type="text" name="kickScooter" id="kickScooter" placeholder='QR code' />
                    </div>
                    <div className="date-order">
                        <h4>Select date</h4>
                        <div className="datePicker">
                            <input type="text" name='dateRange' value={`${Moment(state[0].startDate).format('DD-MM-YYYY')} to ${Moment(state[0].endDate).format('DD-MM-YYYY')}`} readOnly onClick={() => setOpenRegisterDate(!openRegisterDate)} />
                            {
                                openRegisterDate ?
                                    <div ref={refOne} className="dateRange-element">
                                        <DateRange
                                            onChange={item => setState([item.selection])}
                                            ranges={state}
                                            startDatePlaceholder="DD/MM/YYYY"
                                            endDatePlaceholder="daterange"
                                            rangeColors={['#ADC347', "#ffffff"]}
                                        />
                                    </div>
                                    : ""
                            }
                            <span className='icon-datePicker' onClick={() => setOpenRegisterDate(!openRegisterDate)} ><BsFillCalendarFill /></span>
                        </div>
                    </div>
                    <div className="minutes-filter">
                        <h4 htmlFor="minutes">Minutes</h4>
                        <div className="slider-minutes">
                            <ThemeProvider theme={theme}>
                                <Slider
                                    value={value}
                                    onChange={handleChange}
                                    valueLabelDisplay="off"
                                    min={0}
                                    max={100}
                                    color="primary"
                                    size="small"
                                    aria-labelledby="range-slider"
                                />
                            </ThemeProvider>
                            <div className="label-range">
                                <span className='label-min'>{value[0]}</span>
                                <span className='label-max'>{value[1]}</span>
                            </div>
                        </div>

                    </div>
                    <div className="amount-filter">
                        <h4 htmlFor="amount">Amount</h4>
                        <div className="slider-amount">
                            <ThemeProvider theme={theme}>
                                <Slider
                                    value={value}
                                    onChange={handleChange}
                                    valueLabelDisplay="off"
                                    min={0}
                                    max={100}
                                    color="primary"
                                    size="small"
                                    aria-labelledby="range-slider"
                                />
                            </ThemeProvider>
                            <div className="label-range">
                                <span className='label-min'>{value[0]}</span>
                                <span className='label-max'>{value[1]}</span>
                            </div>
                        </div>

                    </div>

                    <div className="buttons-filter">
                        <button className='button-filter'>Reset</button>
                        <button className='button-filter'>Search</button>
                    </div>

                </div>

                <div className="main-order">
                    <div className="table-wrapper">
                        <div className="table-scroll">
                            <table className="table-order">
                                <thead>
                                    <tr>
                                        <th>

                                        </th>
                                        {headCells.map((value) => {
                                            return (
                                                <th scope="col-kicscotter" key={value.id}>{value.label}</th>
                                            )
                                        })}
                                    </tr>
                                </thead>
                                <tbody>
                                    {rows.map((value) => {
                                        return (
                                            <tr key={value.id}>
                                                <th scope="row">
                                                    {value.id}
                                                </th>
                                                <td>{value.qrCode}</td>
                                                <td>{value.account}</td>
                                                <td>{value.minutes}</td>
                                                <td>{value.amount}</td>
                                                <td>{value.meters}</td>
                                                <td>{value.beginTime}</td>
                                                <td>{value.finishTime}</td>
                                                <td>
                                                    <Link className='check-pictures' to='/order-list'>
                                                        Check picture
                                                    </Link>
                                                </td>
                                            </tr>
                                        )
                                    })}

                                </tbody>
                            </table>

                        </div>
                    </div>
                    <div className='table-pagination' >
                        <ThemeProvider theme={theme}>
                            <Pagination color="primary" count={20} page={page} onChange={(event, value) => setPage(value)} />
                        </ThemeProvider>
                    </div>

                </div>
            </div>
        </MasterPage>
    )
}

export default OrderList 