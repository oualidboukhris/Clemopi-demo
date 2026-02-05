import React, { useState } from "react";
import MasterPage from "../../components/masterPage/masterPage";
import "./userList.scss";
import { SlRefresh } from "react-icons/sl";
import { createTheme, Pagination, Slider } from "@mui/material";
import { ThemeProvider } from "@emotion/react";
import "react-date-range/dist/styles.css";
import "react-date-range/dist/theme/default.css";
import { DateRange } from "react-date-range";
import Moment from "moment";
import { IoIosArrowDown } from "react-icons/io";
import { BsFillCalendarFill } from "react-icons/bs";
import { useRef } from "react";
import { useEffect } from "react";
import axios from "axios";
import { useSelector } from "react-redux";
// function createData(id, userId, userName, email, phoneNumber, status,balance,registerChannel,registerTime) {
//     return {
//         id,
//         userId,
//         userName,
//         email,
//         phoneNumber,
//         status,
//         balance,
//         registerChannel,
//         registerTime,
//     };
// }

// const rows = [
//     createData(1, "54828862", "oualid oualid", "oualidboukhris@gmail.com", "065846854", "Enable", "1572","Mobile", "16/01/2020 20:35:20"),
//     createData(2, "64628862", "salma hamada", "salmahamada@gmail.com", "069234657", "Enable", "-15872","Mobile", "22/03/2020 22:35:25"),
//     createData(3, "754828862", "nissrine ha", "nissrineha15@gmail.com", "0675951411", "Enable", "9633","Google", "18/01/2020 08:35:40"),
//     createData(4, "9482885", "mohammed oumalal", "mohammaed2019@gmail.com", "064713852", "Enable", "555","Google", "12/01/2020 23:35:30"),
//     createData(5, "5489267", "anass adnane", "anass_adnane45@gmail.com", "0674726435", "Enable", "12","Mobile", "05/03/2022 00:33:33"),
//     createData(6, "548288629", "ayoub  ha", "ayoub_oo@gmail.com", "0789523641", "Disable", "172","Mobile", "13/09/2020 18:32:45"),
//     createData(7, "54828865", "aziza berrada", "aziza_156@gmail.com", "0698563171", "Enable", "872","Google", "14/01/2022 19:39:44"),
// ];

const headCells = [
  {
    id: "userId",
    label: "User Id",
  },
  {
    id: "userName",
    label: "Username",
  },
  {
    id: "email",
    label: "Email",
  },
  {
    id: "phoneNumber",
    label: "Phone number",
  },
  {
    id: "status",
    label: "Status",
  },
  {
    id: "balance",
    label: "Balance",
  },
  {
    id: "registerChannel",
    label: "Register channel",
  },
  {
    id: "registerTime",
    label: "Register time",
  },
];

const theme = createTheme({
  palette: {
    primary: {
      main: "#ADC347",
    },
  },
});

function UserList() {
  const [currentPage, setCurrentPage] = useState(1);
  const [data, setData] = useState([]);
  const recordsPerPage = 6;
  const lastIndex = currentPage * recordsPerPage;
  const firstIndex = lastIndex - recordsPerPage;
  const [nbrPage, setNbrPage] = useState(0);
  const [filteredData, setFilteredData] = useState([]);
  const [openRegisterDate, setOpenRegisterDate] = useState(false);
  const [dropdownStatus, setDropdownStatus] = useState(false);
  const [dropdownRegister, setDropdownRegister] = useState(false);
  const [valuedropdownStatus, setValuedropdownStatus] = useState("Select all");
  const [valuedropdownRegister, setValuedropdownRegister] = useState("Select all");
  const [valueBalance, setValueBalance] = useState([0, 5000]);
  const {userInfo} = useSelector((state)=>state.auth);
  const refOne = useRef(null);
  const refdropDownStatus = useRef(null);
  const refdropDownRegister = useRef(null);
  
  const handleChange = (event, newValue) => {
    setValueBalance(newValue);
  };
  const [state, setState] = useState([
    {
      startDate: new Date(),
      endDate: new Date(),
      key: "selection",
    },
  ]);
  const [prevStartDate, setPrevStartDate] = useState(state[0].startDate);

  const getDataUser = () => {
    axios
      .get(`${process.env.REACT_APP_URL}/users`, {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
        withCredentials: true,
      })
      .then((res) => {
        setData(res.data);
        setNbrPage(Math.ceil(res.data.length / recordsPerPage));
        const slicedData = res.data.slice(firstIndex, lastIndex);
        setFilteredData(slicedData);
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const parseDateString = (dateString) => {
    const [datePart, timePart] = dateString.split(" ");
    const [day, month, year] = datePart.split("/");
    const [hour, minute, second] = timePart.split(":");

    // Date constructor expects month indices from 0 to 11, so we subtract 1 from the month
    return new Date(year, month - 1, day, hour, minute, second);
  };

  const filterDataUser = () => {
    let filtered = data;
    if (state[0].startDate !== prevStartDate) {
      setPrevStartDate(state[0].startDate);
      filtered = filtered.filter((item) => {
        const date = parseDateString(item.registerTime);
        return (
          date >= new Date(state[0].startDate) &&
          date <= new Date(state[0].endDate)
        );
      });
    }

    if (valueBalance[0] !== 0 || valueBalance[1] !== 5000) {
      filtered = filtered.filter((item) => {
        const balance = item.balance;
        return balance >= valueBalance[0] && balance <= valueBalance[1];
      });
    }

    if (valuedropdownRegister.toLowerCase() !== "select all") {
      filtered = filtered.filter((item) => {
        const registerChannel = item.registerChannel.toLowerCase();
        const valueRegisterChannel = valuedropdownRegister.toLowerCase();
        return (
          valueRegisterChannel.includes(registerChannel) ||
          valueRegisterChannel === "select all"
        );
      });
    }
    if (valuedropdownStatus.toLocaleLowerCase() !== "select all") {
      filtered = filtered.filter((item) => {
        const status = item.status.toLowerCase();
        const valueStatus = valuedropdownStatus.toLowerCase();
        return valueStatus.includes(status) || valueStatus === "select all";
      });
    }
  setFilteredData(filtered);
  };

  const resetDataUser = () => {
    setState([
      {
        startDate: new Date(),
        endDate: new Date(),
        key: "selection",
      },
    ])
    setValueBalance([0,5000]);
    setValuedropdownStatus("Select all");
    setValuedropdownRegister("Select all");
  };
  useEffect(() => {
    getDataUser();
    document.addEventListener("click", hideOnClickOutside, true);
  }, [currentPage]);

  function hideOnClickOutside(e) {
    if (refOne.current && !refOne.current.contains(e.target)) {
      setOpenRegisterDate(false);
    }
    if (
      refdropDownStatus.current &&
      !refdropDownStatus.current.contains(e.target)
    ) {
      setDropdownStatus(false);
    }
    if (
      refdropDownRegister.current &&
      !refdropDownRegister.current.contains(e.target)
    ) {
      setDropdownRegister(false);
    }
  }

  return (
    <MasterPage>
      <div className="UserList">
        <div className="header-user">
          <div className="title-user">{`User list (${data.length} records)`}</div>
          <div className="buttons-user">
            <button className="btn-refresh" onClick={getDataUser}>
              <span className="icon-btn-refresh">
                <SlRefresh />
              </span>
              <span className="title-btn-refresh">Refresh</span>
            </button>
          </div>
        </div>

        <div className="filter-user">
          <div className="register-date">
            <h4>Register date</h4>
            <div className="datePicker">
              <input
                type="text"
                name="dateRange"
                value={`${Moment(state[0].startDate).format(
                  "DD-MM-YYYY"
                )} to ${Moment(state[0].endDate).format("DD-MM-YYYY")}`}
                readOnly
                onClick={() => setOpenRegisterDate(!openRegisterDate)}
              />
              {openRegisterDate ? (
                <div ref={refOne} className="dateRange-element">
                  <DateRange
                    onChange={(item) => setState([item.selection])}
                    ranges={state}
                    startDatePlaceholder="DD/MM/YYYY"
                    endDatePlaceholder="daterange"
                    rangeColors={["#ADC347", "#ffffff"]}
                  />
                </div>
              ) : (
                ""
              )}
              <span
                className="icon-datePicker"
                onClick={() => setOpenRegisterDate(!openRegisterDate)}
              >
                <BsFillCalendarFill />
              </span>
            </div>
          </div>
          <div className="balance-filter">
            <h4 htmlFor="balance">Balance</h4>
            <div className="datePicker">
              <ThemeProvider theme={theme}>
                <Slider
                  value={valueBalance}
                  onChange={handleChange}
                  valueLabelDisplay="off"
                  min={0}
                  max={5000}
                  color="primary"
                  size="small"
                  aria-labelledby="range-slider"
                />
              </ThemeProvider>
              <div className="label-range">
                <span className="label-min">{valueBalance[0]}</span>
                <span className="label-max">{valueBalance[1]}</span>
              </div>
            </div>
          </div>
          <div className="filter-status">
            <h4>Status</h4>
            <div className="dropdown" ref={refdropDownStatus}>
              <div
                className="input-dropdown"
                onClick={() => setDropdownStatus(!dropdownStatus)}
              >
                <input
                  type="text"
                  name="dropdown-input"
                  id="dropdown-input"
                  readOnly
                  value={valuedropdownStatus}
                />
                <span className="dropdown-icon">
                  <IoIosArrowDown />
                </span>
              </div>

              <div className={`option ${dropdownStatus ? "active" : ""}`}>
                <div
                  className="dropdown-item"
                  onClick={() => {
                    setValuedropdownStatus("Select all");
                    setDropdownStatus(false);
                  }}
                >
                  Select all
                </div>
                <div
                  className="dropdown-item"
                  onClick={() => {
                    setValuedropdownStatus("Enable");
                    setDropdownStatus(false);
                  }}
                >
                  Enable
                </div>
                <div
                  className="dropdown-item"
                  onClick={() => {
                    setValuedropdownStatus("Disable");
                    setDropdownStatus(false);
                  }}
                >
                  Disable
                </div>
              </div>
            </div>
          </div>
          <div className="filter-register-channel">
            <h4>Register channel</h4>
            <div className="dropdown" ref={refdropDownRegister}>
              <div
                className="input-dropdown"
                onClick={() => setDropdownRegister(!dropdownRegister)}
              >
                <input
                  type="text"
                  name="dropdown-input"
                  id="dropdown-input"
                  readOnly
                  value={valuedropdownRegister}
                />
                <span className="dropdown-icon">
                  <IoIosArrowDown />
                </span>
              </div>

              <div className={`option ${dropdownRegister ? "active" : ""}`}>
                <div
                  className="dropdown-item"
                  onClick={() => {
                    setValuedropdownRegister("Select all");
                    setDropdownRegister(false);
                  }}
                >
                  Select all
                </div>
                <div
                  className="dropdown-item"
                  onClick={() => {
                    setValuedropdownRegister("Email");
                    setDropdownRegister(false);
                  }}
                >
                  Email
                </div>
                <div
                  className="dropdown-item"
                  onClick={() => {
                    setValuedropdownRegister("Google");
                    setDropdownRegister(false);
                  }}
                >
                  Google
                </div>
              </div>
            </div>
          </div>
          <div className="buttons-filter">
            <button className="button-filter" onClick={resetDataUser}>
              Reset
            </button>
            <button className="button-filter" onClick={filterDataUser}>
              Search
            </button>
          </div>
        </div>

        <div className="main-user">
          <div className="table-wrapper">
            <div className="table-scroll">
              <table className="table-user">
                <thead>
                  <tr>
                    <th></th>
                    {headCells.map((value) => {
                      return (
                        <th scope="col-kicscotter" key={value.id}>
                          {value.label}
                        </th>
                      );
                    })}
                  </tr>
                </thead>
                <tbody>
                  {filteredData.length > 0 ? (
                    filteredData.map((value) => {
                      return (
                        <tr key={value.id}>
                          <th scope="row">{value.id}</th>
                          <td className="userId">{value.userId}</td>
                          <td className="firstName">
                            {value.firstName} {value.lastName}
                          </td>
                          <td className="email">{value.email}</td>
                          <td className="phoneNumber">{value.phoneNumber}</td>
                          <td
                            className={`status ${
                              value.status === "Enable" ? "enable" : "disable"
                            }`}
                          >
                            {value.status}
                          </td>
                          <td
                            className={`balance ${
                              value.balance > 0 ? "" : "red"
                            }`}
                          >
                            {value.balance}
                          </td>
                          <td className="register-channel">
                            {value.registerChannel}
                          </td>
                          <td className="register-time">
                            {value.registerTime}
                          </td>
                        </tr>
                      );
                    })
                  ) : (
                    <tr>
                      <td colSpan={7}>{"No data available."}</td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
          <div className="table-pagination">
            <ThemeProvider theme={theme}>
              <Pagination
                color="primary"
                page={currentPage}
                count={nbrPage}
                onChange={(event, value) => setCurrentPage(value)}
              />
            </ThemeProvider>
          </div>
        </div>
      </div>
    </MasterPage>
  );
}

export default UserList;
