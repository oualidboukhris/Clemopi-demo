import React, { useEffect, useState } from "react";
import MasterPage from "../../components/masterPage/masterPage";
import "./user.scss";
import { IoMdArrowDropdown } from "react-icons/io";
import {
  Alert,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Menu,
  TextField,
} from "@mui/material";
import axios from "axios";
import Cookies from "js-cookie";
import { useSelector } from "react-redux";
import PhotoSwipeLightbox from "photoswipe/lightbox";
import "photoswipe/style.css";
import imageKickscooter from "../../img/e-kickscooter.jpg";

const options = [
  "Uncommitted",
  "Verified",
  "Unverified (Identity card)",
  "Unverified (>= 17 years old)",
  "Blocked",
  "Unverified (Selfie not appropriate)",
];
const statusOption = [
  "Enable",
  'Disable'
]


function User() {
  const [data, setData] = useState("");
  const [anchorElStatus, setAnchorElStatus] = useState(null);
  const [anchorElAccountStatus, setAnchorElAccountStatus] = useState(null);
  const [valueSearch, setValueSearch] = useState(null);
  const open = Boolean(anchorElAccountStatus);
  const openStatus = Boolean(anchorElStatus);
  const [openDialog, setOpenDialog] = useState(false);
  const [balance, setBalance] = useState(null);
  const [selectedIndexState, setSelectedIndexState] = useState(0);
  const [selectedIndexStatus, setSelectedIndexStatus] = useState(0);
  const [alertShow, setAlertShow] = useState({ type: "", message: "" });

  const { userInfo } = useSelector((state) => state.auth);

  const handleMenuItemAccountStatus = (event, index,id) => {
    setSelectedIndexState(index);
    updateAccountStatus(id,index)
    setAnchorElAccountStatus(null);
  };
  
  const handleMenuItemStatus = (event, index,id) => {
    setSelectedIndexStatus(index);
    updateStatus(id,index);
    setAnchorElStatus(null);

  };


  const getDataUser = (userId) => {
    axios
      .get(`${process.env.REACT_APP_URL}/user/${userId}`, {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
        withCredentials: true,
      })
      .then((res) => {
        setData(res.data);
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const updateBalance = async (id) => {
    await axios
      .put(`${process.env.REACT_APP_URL}/balanceUpdate`, {
        userId: id,
        balance: parseInt(balance),
        dateUpdate: "",
      }, {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
      })
      .then((res) => {
        setAlertShow({ type: "success", message: res.data.message });
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const updateAccountStatus = async (id, index) => {
    await axios
      .put(`${process.env.REACT_APP_URL}/accountStatus/${id}`, {
        accountStatus: options[index],
      }, {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
      })
      .then((res) => {
        setAlertShow({ type: "success", message: res.data.message });
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const updateStatus = async (id,index) => {
    await axios
      .put(`${process.env.REACT_APP_URL}/disbaleStatus/${id}`, {
        status:statusOption[index]
      })
      .then((res) => {
        setAlertShow({ type: "success", message: res.data.message });
      })
      .catch((err) => {
        console.log(err);
      });
  };

  // const showDriverPhotos = async (id) => {
  //   await axios
  //     .put(`${process.env.REACT_APP_URL}/balanceUpdate`, {
  //       userId: id,
  //       balance: parseInt(balance),
  //       dateUpdate: "",
  //     })
  //     .then((res) => {
  //       setAlertShow({ type: "success", message: res.data.message });
  //     })
  //     .catch((err) => {
  //       console.log(err);
  //     });
  // };

  useEffect(() => {
    const lightbox = new PhotoSwipeLightbox({
      gallery: "#my-gallery",
      children: "a",
      imageClickAction: "next",
      tapAction: "next",
      pswpModule: () => import("photoswipe"),
    });
    lightbox.init();
  }, []);

  return (
    <MasterPage>
     
      <div className="user-searching">
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
              id="search-user"
              placeholder="User id"
              onChange={(e) => setValueSearch(e.currentTarget.value)}
            />
            <button
              className="search-button"
              onClick={() => getDataUser(valueSearch)}
            >
              Search
            </button>
          </div>
          <div className="buttons-update">
            <div className="menu">
              <button
                disabled={
                  data.length === 0 || data.error === true ? true : false
                }
                onClick={(event) => setAnchorElAccountStatus(event.currentTarget)}
              >
                <span className="title-menu">
                  {options[selectedIndexState]}
                </span>
                <span className="icon-menu">
                  <IoMdArrowDropdown />
                </span>
              </button>
              <Menu
                id="basic-menu"
                anchorEl={anchorElAccountStatus}
                open={open}
                onClose={() => setAnchorElAccountStatus(null)}
              >
                {options.map((option, index) => {
                  return (
                    <li
                      className="list-menu"
                      key={option}
                      disabled={index === 0}
                      selected={index === selectedIndexState}
                      onClick={(event) => {
                        handleMenuItemAccountStatus(event, index,data.userId);
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
              show
            </button>

            <button
              className="user-operation"
              disabled={data.length === 0 || data.error === true ? true : false}
            >
              Delete
            </button>
            <div className="menu">
              <button
                disabled={
                  data.length === 0 || data.error === true ? true : false
                }
                onClick={(event) => setAnchorElStatus(event.currentTarget)}
              >
                <span className="title-menu">
                  {statusOption[selectedIndexStatus]}
                </span>
                <span className="icon-menu">
                  <IoMdArrowDropdown />
                </span>
              </button>
              <Menu
                id="basic-menu"
                anchorEl={anchorElStatus}
                open={openStatus}
                onClose={() => setAnchorElStatus(null)}
              >
                {statusOption.map((option, index) => {
                  return (
                    <li
                      className="list-menu"
                      key={option}
                      disabled={index === 0}
                      selected={index === selectedIndexState}
                      onClick={(event) => {
                        handleMenuItemStatus(event, index,data.userId);
                      }}
                    >
                      {option}
                    </li>
                  );
                })}
              </Menu>
            </div>
            <button
              className="driver-photos"
              disabled={data.length === 0 || data.error === true ? true : false}
            >
              <div id="my-gallery">
                <a
                  href={imageKickscooter}
                  data-pswp-width="800"
                  data-pswp-height="800"
                  className={data.length === 0 || data.error === true ? "disabled" : ""}
                >
                  Driver photos
                </a>
              </div>
            </button>
            <button
              className="payment"
              disabled={data.length === 0 || data.error === true ? true : false}
              onClick={
                data === "" ? () => false : () => setOpenDialog(!openDialog)
              }
            >
              Payment
            </button>

            <Dialog open={openDialog} onClose={() => setOpenDialog(false)}>
              <DialogTitle id="dialog-title">Payement</DialogTitle>
              <DialogContent>
                <div className="content-dialog">
                  <div className="form-group">
                    <div className="form-item">
                      <label htmlFor="amount">Amount</label>
                      <TextField
                        id="filled-hidden-label-small"
                        variant="filled"
                        size="small"
                        sx={{
                          ".MuiInputBase-input": { padding: 0.5 },
                          "& .MuiInput-underline:before": {
                            borderBottomColor: "orange",
                          },
                          "& .MuiInput-underline:after": {
                            borderBottomColor: "orange",
                          },
                        }}
                        onChange={(e) => setBalance(e.currentTarget.value)}
                      />
                    </div>
                  </div>
                </div>
              </DialogContent>
              <DialogActions>
                <Button
                  color="success"
                  onClick={() => updateBalance(data.userId)}
                >
                  Update
                </Button>
                <Button color="success" onClick={() => setOpenDialog(false)}>
                  cancel
                </Button>
              </DialogActions>
            </Dialog>
          </div>
        </div>
        <div className="user-informations">
          <div className="content-information">
            <div className="info-item">
              <label htmlFor="qrCode">UserID</label>
              <input
                type="text"
                name="qrCode"
                defaultValue={data ? data.userId : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="speed">Email</label>
              <input
                type="text"
                name="speed"
                defaultValue={data ? data.email : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="headlamp">Phone number</label>
              <input
                type="text"
                name="headlamp"
                defaultValue={data ? data.phoneNumber : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="disableState">Username</label>
              <input
                type="text"
                name="disableState"
                defaultValue={data ? data.username : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="visibleState">First name</label>
              <input
                type="text"
                name="visibleState"
                defaultValue={data ? data.firstName : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="alarmState">Last name</label>
              <input
                type="text"
                name="alarmState"
                defaultValue={data ? data.lastName : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="orderState">Gender</label>
              <input
                type="text"
                name="orderState"
                defaultValue={data ? data.gender : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="lockState">Age</label>
              <input
                type="text"
                name="lockState"
                defaultValue={data ? data.age : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="communicationTime">Birthday</label>
              <input
                type="text"
                name="totalMinutes"
                defaultValue={data ? data.birthday : ""}
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
              <label htmlFor="battery">Balance</label>
              <input
                type="text"
                name="battery"
                defaultValue={data ? data.balance : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="coords">Total minutes</label>
              <input
                type="text"
                name="coords"
                defaultValue={data ? data.totalMinutes : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="totalMeters">Total meters</label>
              <input
                type="text"
                name="totalMeters"
                defaultValue={data ? data.totalMeters : ""}
                disabled
              />
            </div>

            <div className="info-item">
              <label htmlFor="totalAmounts">Total orders</label>
              <input
                type="text"
                name="totalAmounts"
                defaultValue={data ? data.totalOrders : ""}
                disabled
              />
            </div>

            <div className="info-item">
              <label htmlFor="totalOrders">Register channel</label>
              <input
                type="text"
                name="totalOrders"
                defaultValue={data ? data.registerChannel : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="bleutoothPassword">Status</label>
              <input
                type="text"
                name="bleutoothPassword"
                defaultValue={data ? data.status : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="registerTime">Register time</label>
              <input
                type="text"
                name="registerTime"
                defaultValue={data ? data.registerTime : ""}
                disabled
              />
            </div>

            <div className="info-item">
              <label htmlFor="authenticationCode">Last order time</label>
              <input
                type="text"
                name="totalMinutes"
                defaultValue={data ? data.lastOrderTime : ""}
                disabled
              />
            </div>
            <div className="info-item">
              <label htmlFor="keyState">Account status</label>
              <input
                type="text"
                name="totalMinutes"
                defaultValue={data ? data.accountStatus : ""}
                disabled
              />
            </div>

            <div className="info-item">
              <label htmlFor="unlockingWay">Unlocking way</label>
              <input
                type="text"
                name="region"
                defaultValue={data ? data.unlockingWay : ""}
                disabled
              />
            </div>
          </div>
        </div>
      </div>
    </MasterPage>
  );
}

export default User;
