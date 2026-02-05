import React, { useContext, useEffect, useState } from "react";
import "./settings.scss";
import imgProfil from "../../img/e-kickscooter.jpg";
import imgCover from "../../img/cover.png";
import PropTypes from "prop-types";
import MasterPage from "../../components/masterPage/masterPage";
import { Alert, Avatar, Box, IconButton, Tab, Tabs } from "@mui/material";
import { BsCameraFill } from "react-icons/bs";
import axios from "axios";
import Cookies from "js-cookie";
import { MdEmail } from "react-icons/md";
import PhoneInput from "react-phone-input-2";
import "react-phone-input-2/lib/style.css";
import { useSelector } from "react-redux";

function TabPanel(props) {
  const { children, value, index, ...other } = props;
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`simple-tabpanel-${index}`}
      aria-labelledby={`simple-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ p: 3 }}>{children}</Box>}
    </div>
  );
}

TabPanel.propTypes = {
  children: PropTypes.node,
  index: PropTypes.number.isRequired,
  value: PropTypes.number.isRequired,
};

function a11yProps(index) {
  return {
    id: `simple-tab-${index}`,
    "aria-controls": `simple-tabpanel-${index}`,
  };
}
axios.defaults.withCredentials = true;

function Settings() {
  const [value, setValue] = useState(0);
  const [phoneNumber, setPhoneNumber] = useState("");
  const [dataUserValues, setDataUserValues] = useState({
    firstName: "",
    lastName: "",
    email: "",
    createdAt: "",
  });

  const [dataPasswordValues, setDataPasswordValues] = useState({
    currentPassword: "",
    newPassword: "",
    confirmationPassword: "",
  });

  const [errorsUser, setErrorsUser] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phoneNumber: "",
  });

  const [errors, setErrors] = useState({
    currentPassword: "",
    newPassword: "",
    confirmationPassword: "",
  });

  const [alertMessage, setAlertMessage] = useState({ type: "", message: "" });
  const [imageUrl, setImageUrl] = useState(null);
  const {userInfo} = useSelector((state)=>state.auth);
  const userId = userInfo.xsrfToken.split("%")[1];

  const validateFormUser = () => {
    const newErrorsUser = {};
    if (!dataUserValues.firstName) {
      newErrorsUser.firstName = "First name is required";
    }
    if (!dataUserValues.lastName) {
      newErrorsUser.lastName = "Last name is required";
    }
    if (!dataUserValues.email) {
      newErrorsUser.email = "Email is required";
    } else if (!/\S+@\S+\.\S+/.test(dataUserValues.email)) {
      newErrorsUser.email = "Email is invalid";
    }
    setErrorsUser(newErrorsUser);
    return Object.keys(newErrorsUser).length === 0;
  };

  const validateFormPassword = () => {
    const newErrors = {};
    if (!dataPasswordValues.currentPassword) {
      newErrors.currentPassword = "Please enter your password";
    } else if (
      dataPasswordValues.currentPassword.length < 4 &&
      dataPasswordValues.currentPassword.length < 20
    ) {
      newErrors.currentPassword =
        "Your password must contain between 4 and 20 characters.";
    }

    if (!dataPasswordValues.newPassword) {
      newErrors.newPassword = "Please enter your password";
    } else if (
      dataPasswordValues.newPassword.length < 4 &&
      dataPasswordValues.newPassword.length < 20
    ) {
      newErrors.newPassword =
        "Your password must contain between 4 and 20 characters.";
    } else if (
      dataPasswordValues.confirmationPassword !== dataPasswordValues.newPassword
    ) {
      newErrors.confirmationPassword =
        "Password confirmation doesn't match the password.";
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (event, newValue) => {
    setValue(newValue);
  };

  const handleChangeUserValues = (event) => {
    const { name, value } = event.target;
    setDataUserValues((prevValues) => ({
      ...prevValues,
      [name]: value,
    }));
  };

  const handleChangePasswordValues = (event) => {
    const { name, value } = event.target;
    setDataPasswordValues((prevValues) => ({
      ...prevValues,
      [name]: value,
    }));
  };

  const handleUpload = async (event) => {
    const file = event.target.files[0];
    const formData = new FormData();
    formData.append("image", file);

    try {
      const response = await axios.post(
        `${process.env.REACT_APP_URL}/upload/${userId}`,
        formData,
        {
          headers: {
            "Content-Type": "multipart/form-data",
            "x-xsrf-token": userInfo.xsrfToken,
          },
        }
      );
   
    
    } catch (error) {
      console.error("Error uploading file:", error);
    }
  };

  const handleUpdate = async (e) => {
    e.preventDefault();
    if (e.type === "click" || e.key === "Enter") {
      if (validateFormUser()) {
        try {
          await axios
            .put(
              `${process.env.REACT_APP_URL}/users/${userId}`,
              {...dataUserValues,phoneNumber:phoneNumber}
              ,
              {
                headers: {
                  "x-xsrf-token": userInfo.xsrfToken,
                },
              }
            )
            .then((res) => {
              setAlertMessage({ type: "success", message: res.data.message });
            })
            .catch((err) => {
              setAlertMessage({ type: "error", message: err.data.message });
            });
        } catch (error) {
          console.error("Error uploading file:", error);
        }
      }
    }
  };

  const getDataUser = async () => {
    try {
      const response = await axios.get(
        `${process.env.REACT_APP_URL}/users/${userId}`,
        {
          headers: {
            "x-xsrf-token": userInfo.xsrfToken,
          },
        }
      );
      setPhoneNumber(response.data.phone);
      setDataUserValues({
        firstName: response.data.firstName,
        lastName: response.data.lastName,
        email: response.data.email,
        createdAt: response.data.createdAt,
      });
      console.log(response.data)
      setImageUrl(response.data.image_url);
    } catch (error) {
      console.error("Error uploading file:", error);
    }
  };

  const updatePassword = async (e) => {
    if (e.type === "click" || e.key === "Enter") {
      if (validateFormPassword()) {
        await axios
          .put(
            `${process.env.REACT_APP_URL}/users/changePassword`,
            {
              username: dataUserValues.email,
              currentPassword: dataPasswordValues.currentPassword,
              newPassword: dataPasswordValues.newPassword,
            },
            {
              headers: {
                "x-xsrf-token": userInfo.xsrfToken,
              },
            }
          )
          .then((res) => {
            setAlertMessage({ type: "success", message: res.data.message });
            setDataPasswordValues({
              currentPassword: "",
              newPassword: "",
              confirmationPassword: "",
            });
          })
          .catch((err) => {
            setAlertMessage({
              type: "error",
              message: "Your current password did not match",
            });
          });
      }
    }
  };

  useEffect(() => {
    getDataUser();
  }, []);

  return (
    <MasterPage>
      <div className="settings-container">
        {alertMessage.type && (
          <div className="alert-message">
            <Alert
              severity={alertMessage.type === "error" ? "error" : "success"}
              onClose={() => setAlertMessage({ type: "", message: "" })}
            >
              {alertMessage.message}
            </Alert>
          </div>
        )}
        <div className="settings-header">
          <div className="cover-image">
            <img src={imgCover} alt="image-cover" />
          </div>
          <div className="profil-image">
            <Avatar
              src={imageUrl && `${process.env.REACT_APP_URL_IMAGE}/${imageUrl}`}
              sx={{
                width: 150,
                height: 150,
                objectFit: "cover",
                borderRadius: "50%", // Make it a circle
                boxShadow: "0 4px 8px rgba(0, 0, 0, 0.5)",
                backgroundColor: "gray",
              }}
            ></Avatar>
            <div className="upload-image">
              <Avatar
                sx={{
                  width: 40,
                  height: 40,
                  backgroundColor: "#ECECEE",
                }}
              >
                <div className="icon-upload-image">
                  <input
                    type="file"
                    accept="image/*"
                    style={{ display: "none" }}
                    id="image-input"
                    onChange={handleUpload}
                  />
                  <label htmlFor="image-input">
                    <IconButton component="span">
                      <BsCameraFill color="#000000" size={20} />
                    </IconButton>
                  </label>
                </div>
              </Avatar>
            </div>
          </div>
        </div>
        <div className="setting-body">
          <Box sx={{ width: "100%" }}>
            <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
              <Tabs
                value={value}
                onChange={handleChange}
                TabIndicatorProps={{
                  style: {
                    backgroundColor: "#adc347",
                  },
                }}
                sx={{ "& button.Mui-selected": { color: "#adc347" } }}
              >
                <Tab label="Personal Details" {...a11yProps(0)} />
                <Tab label="Change Password" {...a11yProps(1)} />
              </Tabs>
            </Box>
            <TabPanel value={value} index={0}>
              <div className="form-personal-details">
                <form>
                  <div className="form-group">
                    <label htmlFor="firstName">First name</label>
                    <input
                      type="text"
                      className="first-name"
                      name="firstName"
                      id="inputFirstname"
                      value={dataUserValues.firstName}
                      onChange={handleChangeUserValues}
                    />

                    {errorsUser.firstName && (
                      <span className="validationForm">
                        {errorsUser.firstName}
                      </span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="lastName">Last name</label>
                    <input
                      type="text"
                      className="last-name"
                      name="lastName"
                      id="inputLastname"
                      value={dataUserValues.lastName}
                      onChange={handleChangeUserValues}
                    />
                    {errorsUser.lastName && (
                      <span className="validationForm">
                        {errorsUser.lastName}
                      </span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="phoneNumber">Phone Number</label>
                    <PhoneInput
                      className="phone-number"
                      country={"ma"}
                      inputProps={{
                        required: true,
                      }}
                      name="phoneNumber"
                      value={phoneNumber}
                      onChange={(phone) => setPhoneNumber(phone)}
                    />
                    {errorsUser.lastName && (
                      <span className="validationForm">
                        {errorsUser.phoneNumber}
                      </span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="email">Email</label>
                    <input
                      type="text"
                      className="email"
                      name="email"
                      id="inputEmail"
                      value={dataUserValues.email}
                      onChange={handleChangeUserValues}
                    />
                    {errorsUser.email && (
                      <span className="validationForm">{errorsUser.email}</span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="phoneNumber">Joining Date</label>
                    <input
                      type="text"
                      disabled
                      className="createdAt"
                      name="createdAt"
                      id="inputCreatedAt"
                      value={dataUserValues.createdAt}
                      onChange={handleChangeUserValues}
                    />
                  </div>
                </form>
                <div className="form-buttons">
                  <button className="update-button" onClick={handleUpdate}>
                    Update
                  </button>
                  {/* <button className="cancel-button">Cancel</button> */}
                </div>
              </div>
            </TabPanel>
            <TabPanel value={value} index={1}>
              <div className="form-password">
                <form>
                  <div className="form-group">
                    <label htmlFor="currentPassword">
                      Current Password<span style={{ color: "red" }}>*</span>
                    </label>
                    <input
                      type="password"
                      id="inputPassword"
                      name="currentPassword"
                      placeholder="Enter current password"
                      value={dataPasswordValues.currentPassword}
                      className={`input-item ${
                        errors.currentPassword === undefined ||
                        errors.currentPassword === ""
                          ? ""
                          : "invalid"
                      }`}
                      onChange={handleChangePasswordValues}
                    />
                    {errors.currentPassword && (
                      <span className="validationForm">
                        {errors.currentPassword}
                      </span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="password">
                      New password<span style={{ color: "red" }}>*</span>
                    </label>
                    <input
                      autoComplete="off"
                      type="password"
                      name="newPassword"
                      id="password"
                      value={dataPasswordValues.newPassword}
                      className={`input-item ${
                        errors.newPassword === undefined ||
                        errors.newPassword === ""
                          ? ""
                          : "invalid"
                      }`}
                      onChange={handleChangePasswordValues}
                    />
                    {errors.newPassword && (
                      <span className="validationForm">
                        {errors.newPassword}
                      </span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="confirmationPassword">
                      Confirm new Password
                      <span style={{ color: "red" }}>*</span>
                    </label>
                    <input
                      autoComplete="off"
                      type="password"
                      name="confirmationPassword"
                      id="confirmationPassword"
                      value={dataPasswordValues.confirmationPassword}
                      className={`input-item ${
                        errors.confirmationPassword === undefined ||
                        errors.confirmationPassword === ""
                          ? ""
                          : "invalid"
                      }`}
                      onChange={handleChangePasswordValues}
                    />
                    {errors.confirmationPassword === "null" ? (
                      ""
                    ) : (
                      <span className="validationForm">
                        {errors.confirmationPassword}
                      </span>
                    )}
                  </div>
                </form>
                <div className="form-buttons">
                  <button className="change-button" onClick={updatePassword}>
                    Change Password
                  </button>
                </div>
              </div>
            </TabPanel>
          </Box>
        </div>
      </div>
    </MasterPage>
  );
}

export default Settings;
