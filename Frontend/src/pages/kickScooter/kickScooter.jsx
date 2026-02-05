import React, { useState } from "react";
import MasterPage from "../../components/masterPage/masterPage";
import "./kickScooter.scss";
import imageKickscooter from "../../img/e-kickscooter.jpg";
import { IoMdArrowDropdown } from "react-icons/io";
import { Alert, Menu, MenuItem } from "@mui/material";
import Fade from "@mui/material/Fade";
import axios from "axios";
import { useSelector } from "react-redux";


const options = [
  "Profil",
  "Lost-Forever",
  "Lost-Stolen",
  "Repair-Not Urgent",
  "Repair-Van",
  "Repair-Workshop",
  "Repair-Warehouse",
  "Repair-Urgent",
  "Normal ",
];
const keyState = ["No set", "Successful"];

function KickScooter() {
  const [anchorElStatus, setAnchorElStatus] = useState(null);
  const [anchorElKeyState, setAnchorElKeyState] = useState(null);
  const [selectedIndex, setSelectedIndex] = React.useState(0);
  const [selectedIndexKeyState, setSelectedIndexkeyKtate] = React.useState(0);
  const [valueSearch, setValueSearch] = useState(null);
  const [data, setData] = useState([]);
  const [alertShow, setAlertShow] = useState({
    type: "",
    message: "",
  });

  const openKey = Boolean(anchorElKeyState);
  const open = Boolean(anchorElStatus);
  const {userInfo} = useSelector((state)=>state.auth);

  const handleMenuItemClick = (event, index) => {
    setSelectedIndex(index);
    setAnchorElStatus(null);
    updateDisbaleState(data.id, options[index]);
  };

  const handleMenuItemKeyStateClick = (event, index) => {
    setSelectedIndexkeyKtate(index);
    setAnchorElKeyState(null);
    updateKeyState(data.id, keyState[index]);
  };

  const getDataKickscooter = async (qrCode) => {
    if (qrCode !== null || qrCode !== "") {
      await axios
        .get(`${process.env.REACT_APP_URL}/kickscooter/${qrCode}`, {
          headers: {
            "x-xsrf-token": userInfo.xsrfToken,
          },
          withCredentials: true,
        })
        .then((res) => {
          if (res.data.error === true) {
            setAlertShow({
              type: "error",
              message: res.data.message,
            });
          } else {
            setData(res.data);
          }
        })
        .catch((err) => {
          setAlertShow({
            type: "error",
            message: "Internal server",
          });
        });
    } else {
      setAlertShow({
        error: true,
        message: "kickScooter not exist",
      });
    }
  };
  const updateDisbaleState = async (id, disableState) => {
    await axios
      .put(
        `${process.env.REACT_APP_URL}/kickscooters`,
        {
          idScooters: id,
          disable_state: disableState,
        },
        {
          headers: {
            "x-xsrf-token": userInfo.xsrfToken,
          },
        }
      )
      .then((res) => {
        setAlertShow({
          type: "success",
          message: res.data.message,
        });
      })
      .catch((err) => {
        console.log(err);
      });
  };
  const updateKeyState = async (id, keyState) => {
    await axios
      .put(
        `${process.env.REACT_APP_URL}/kickscooter/key-state`,
        {
          idScooters: id,
          key_state: keyState,
        },
        {
          headers: {
            "x-xsrf-token": userInfo.xsrfToken,
          },
        }
      )
      .then((res) => {
        setAlertShow({
          type: "success",
          message: res.data.message,
        });
      })
      .catch((err) => {
        console.log(err);
      });
  };

  return (
    <MasterPage>
      <div className="kickScooter-searching">
        {alertShow.type && (
          <div className="alert-message">
            <Alert
              severity={alertShow.type === "error" ? "error" : "success"}
              onClose={() => setAlertShow({ type: "", message: "" })}
            >
              {alertShow.message}
            </Alert>
          </div>
        )}
        <div className="header-searching">
          <div className="input-search">
            <input
              type="text"
              name="search"
              id="search-kickScooter"
              placeholder="QrCode"
              onChange={(e) => {
                setValueSearch(e.target.value);
              }}
            />
            <button
              className="search-button"
              onClick={() => getDataKickscooter(valueSearch)}
            >
              Search
            </button>
          </div>
          <div className="buttons-update">
            <div className="disable-state-menu">
              <button
                onClick={(event) => setAnchorElStatus(event.currentTarget)}
                disabled={
                  data.length === 0 || data.error === true ? true : false
                }
              >
                <span className="title-menu">{options[selectedIndex]}</span>
                <span className="icon-menu">
                  <IoMdArrowDropdown />
                </span>
              </button>
              <Menu
                id="basic-menu"
                anchorEl={anchorElStatus}
                open={open}
                onClose={() => setAnchorElStatus(null)}
              >
                {options.map((option, index) => {
                  return (
                    <li
                      className="list-menu"
                      key={option}
                      disabled={index === 0}
                      selected={index === selectedIndex}
                      onClick={(event) => {
                        handleMenuItemClick(event, index);
                      }}
                    >
                      {option}
                    </li>
                  );
                })}
              </Menu>
            </div>
            <button
              className="region"
              disabled={data.length === 0 || data.error === true ? true : false}
            >
              Show
            </button>
            <button
              className="kickScooter-operation"
              disabled={data.length === 0 || data.error === true ? true : false}
            >
              Kick scooter Operation
            </button>
            <div
              className="key-state-menu"
              onClick={(event) => setAnchorElKeyState(event.currentTarget)}
            >
              <button
                disabled={
                  data.length === 0 || data.error === true ? true : false
                }
              >
                <span className="title-menu">
                  Key state: {keyState[selectedIndexKeyState]}
                </span>
                <span className="icon-menu">
                  <IoMdArrowDropdown />
                </span>
              </button>
            </div>
            <Menu
              id="basic-menu"
              anchorEl={anchorElKeyState}
              open={openKey}
              TransitionComponent={Fade}
              onClose={() => setAnchorElKeyState(null)}
              style={{ marginTop: 32, marginLeft: 8 }}
              anchorOrigin={{ vertical: "top", horizontal: "left" }}
            >
              {keyState.map((keyState, index) => {
                return (
                  <li
                    className="list-menu"
                    key={keyState}
                    disabled={index === 0}
                    selected={index === selectedIndexKeyState}
                    onClick={(event) => {
                      handleMenuItemKeyStateClick(event, index);
                    }}
                  >
                    {keyState}
                  </li>
                );
              })}
            </Menu>
          </div>
        </div>
        <div className="kickScooter-informations">
          <div className="content-information">
            <div className="info-item">
              <img src={imageKickscooter} alt="Kickscooter not found" />
            </div>
            <div className="info-item">
              <label htmlFor="qrCode">QR Code</label>
              <input
                type="text"
                name="qrCode"
                defaultValue={data ? data.qrCode : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="speed">Speed</label>
              <input
                type="text"
                name="speed"
                defaultValue={data ? data.speed : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="headlamp">Headlamp</label>
              <input
                type="text"
                name="headlamp"
                defaultValue={data ? data.head_lamp : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="disableState">Disable state</label>
              <input
                type="text"
                name="disableState"
                defaultValue={data ? data.disable_state : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="visibleState">Visible state</label>
              <input
                type="text"
                name="visibleState"
                defaultValue={data ? data.visible_state : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="alarmState">Alarm state</label>
              <input
                type="text"
                name="alarmState"
                defaultValue={data ? data.alarm_state : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="orderState">Order state</label>
              <input
                type="text"
                name="orderState"
                defaultValue={data ? data.order_state : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="lockState">Lock state</label>
              <input
                type="text"
                name="lockState"
                defaultValue={data ? data.lock_state : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="battery">Battery</label>
              <input
                type="text"
                name="battery"
                defaultValue={data ? data.battery : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="coords">Coords</label>
              <input
                type="text"
                name="coords"
                defaultValue={data ? data.coords : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="totalMeters">Total meters</label>
              <input
                type="text"
                name="totalMeters"
                defaultValue={data ? data.total_meters : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="totalMinutes">Total minutes</label>
              <input
                type="text"
                name="totalMinutes"
                defaultValue={data ? data.total_minutes : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="totalAmounts">Total amounts</label>
              <input
                type="text"
                name="totalAmounts"
                defaultValue={data ? data.total_amounts : ""}
                disabled
              />
            </div>

            <div className="info-item">
              <label htmlFor="totalOrders">Total orders</label>
              <input
                type="text"
                name="totalOrders"
                defaultValue={data ? data.total_orders : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="bleutoothKey">Bleutooth key</label>
              <input
                type="text"
                name="bleutoothKey"
                defaultValue={data ? data.bleutooth_key : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="bleutoothPassword">Bleutooth password</label>
              <input
                type="text"
                name="bleutoothPassword"
                defaultValue={data ? data.bleutooth_password : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="registerTime">Register time</label>
              <input
                type="text"
                name="registerTime"
                defaultValue={data ? data.register_time : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="communicationTime">Communication time</label>
              <input
                type="text"
                name="totalMinutes"
                defaultValue={data ? data.communication_time : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="authenticationCode">Authentication code</label>
              <input
                type="text"
                name="totalMinutes"
                defaultValue={data ? data.authentication_code : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="keyState">Key state</label>
              <input
                type="text"
                name="totalMinutes"
                defaultValue={data ? data.key_state : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="region">Region</label>
              <input
                type="text"
                name="region"
                defaultValue={data ? data.region : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="unlockingWay">Unlocking way</label>
              <input
                type="text"
                name="region"
                defaultValue={data ? data.unlocking_way : ""}
                disabled
              />
            </div>
          </div>
        </div>
      </div>
    </MasterPage>
  );
}

export default KickScooter;
