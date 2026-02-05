import React, { useEffect, useRef, useState } from "react";
import MasterPage from "../../components/masterPage/masterPage";
import "./kickScooterList.scss";
import { AiOutlineCloudUpload } from "react-icons/ai";
import { SlRefresh } from "react-icons/sl";
import { MdSave } from "react-icons/md";
import {
  Alert,
  Button,
  createTheme,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControl,
  InputLabel,
  MenuItem,
  Pagination,
  Select,
  TextField,
} from "@mui/material";
import { ThemeProvider } from "@emotion/react";
import axios from "axios";
import { IoIosArrowDown } from "react-icons/io";
import { useSelector } from "react-redux";

const headCells = [
  {
    id: "qrCode",
    label: "QR code",
  },
  {
    id: "visibleState",
    label: "Visible state",
  },
  {
    id: "disableState",
    label: "Disable state",
  },
  {
    id: "battery",
    label: "Battery",
  },
  {
    id: "location",
    label: "Location",
  },
  {
    id: "stationLock",
    label: "Station Lock",
  },
  {
    id: "scooterLock",
    label: "Scooter Lock",
  },
  {
    id: "status",
    label: "Status",
  },
];
const theme = createTheme({
  palette: {
    primary: {
      main: "#ADC347",
    },
  },
});

function KickScooterList() {
  const [currentPage, setCurrentPage] = useState(1);
  const [data, setData] = useState([]);
  const { userInfo } = useSelector((state) => state.auth);
  const [filtersBattery, setFiltersBattery] = useState([]);
  const [filtersVisibleState, setFiltersVisibleState] = useState([]);
  const [filtersDisableState, setFiltersDisableState] = useState([]);
  const [filteredData, setFilteredData] = useState([]);
  const [stationLockChanges, setStationLockChanges] = useState({}); // Track station lock changes
  const [scooterLockChanges, setScooterLockChanges] = useState({}); // Track scooter lock changes
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false); // Track if there are unsaved changes
  const recordsPerPage = 6;
  const lastIndex = currentPage * recordsPerPage;
  const firstIndex = lastIndex - recordsPerPage;
  const [nbrPage, setNbrPage] = useState(0);
  const [openDialog, setOpenDialog] = useState(false);
  const [disableState, setDisableState] = useState("");
  const [errorDisableState, setErrorDisableState] = useState(false);
  const [alertShow, setAlertShow] = useState({
    type: "",
    message: "",
  });

  const handleCheckboxChange = (itemQrCode) => {
    const updatedItems = filteredData.map((item) =>
      item.qrCode === itemQrCode ? { ...item, checked: !item.checked } : item
    );
    setFilteredData(updatedItems);
  };
  const handleCheckAllChange = () => {
    const allChecked = filteredData.every((item) => item.checked);
    const updatedItems = filteredData.map((item) => ({
      ...item,
      checked: !allChecked,
    }));
    setFilteredData(updatedItems);
  };
  const handleChangeBattery = (event) => {
    const { value, checked } = event.target;
    if (checked) {
      setFiltersBattery((prevFilters) => [...prevFilters, value]);
    } else {
      setFiltersBattery((prevFilters) =>
        prevFilters.filter((filter) => filter !== value)
      );
    }
  };
  const handleChangeVisibleState = (event) => {
    const { value, checked } = event.target;
    if (checked) {
      setFiltersVisibleState((prevFilters) => [...prevFilters, value]);
    } else {
      setFiltersVisibleState((prevFilters) =>
        prevFilters.filter((filter) => filter !== value)
      );
    }
  };
  const handleChangeDisableState = (event) => {
    const { value, checked } = event.target;
    if (checked) {
      setFiltersDisableState((prevFilters) => [...prevFilters, value]);
    } else {
      setFiltersDisableState((prevFilters) =>
        prevFilters.filter((filter) => filter !== value)
      );
    }
  };
  const handleChangeSelect = (event) => {
    setDisableState(event.target.value);
    setErrorDisableState(false);
  };

  const getDataScooter = async () => {
    await axios
      .get(`${process.env.REACT_APP_URL}/kickscooters`, {
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
  const exportDataToExcel = async () => {
    const response = await axios.get(
      `${process.env.REACT_APP_URL}/downloadExcel`,
      {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
        withCredentials: true,
        responseType: "arraybuffer",
      }
    );
    const blob = new Blob([response.data], {
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", "KickScooters.xlsx");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  const resetTable = () => {
    setFiltersBattery([]);
    setFiltersVisibleState([]);
    setFiltersDisableState([]);
  };
  const filterTable = () => {
    const filtered =
      filtersBattery.length === 0 &&
      filtersDisableState.length === 0 &&
      filtersVisibleState.length === 0
        ? data
        : data.filter(
            (item) =>
              filtersBattery.some((range) => {
                const [min, max] = range.split(",").map(Number);
                return (
                  parseInt(item.battery) >= min && parseInt(item.battery) <= max
                );
              }) ||
              filtersDisableState.includes(item.disable_state) ||
              filtersVisibleState.includes(item.visible_state)
          );
    const slicedData = filtered.slice(0, recordsPerPage);
    setFilteredData(slicedData);
    setNbrPage(Math.ceil(filtered.length / recordsPerPage));
  };
  const updateItem = async () => {
    const ids = [];
    const filtredData = filteredData.filter((value) => value.checked === true);
    filtredData.map((value) => ids.push(value.id));
    if (disableState) {
      await axios
        .put(
          `${process.env.REACT_APP_URL}/kickscooters`,
          {
            idScooters: ids,
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
    } else {
      setErrorDisableState(true);
    }
  };

  // Save lock state changes
  const saveLockStateChanges = async () => {
    const totalChanges = Object.keys(stationLockChanges).length + Object.keys(scooterLockChanges).length;
    
    if (totalChanges === 0) {
      setAlertShow({
        type: "warning",
        message: "No changes to save",
      });
      setTimeout(() => setAlertShow({ type: "", message: "" }), 3000);
      return;
    }

    let successCount = 0;
    let errorCount = 0;

    // Process station lock changes
    for (const [qrCode, newLockState] of Object.entries(stationLockChanges)) {
      try {
        const endpoint =
          newLockState === "true" ? "/kickscooter/station-lock" : "/kickscooter/station-unlock";
        const response = await axios.post(
          `${process.env.REACT_APP_URL}${endpoint}`,
          { qrCode: qrCode },
          {
            headers: {
              "Content-Type": "application/json",
              "x-xsrf-token": userInfo.xsrfToken,
            },
            withCredentials: true,
          }
        );

        if (response.data.error === false) {
          successCount++;
        } else {
          errorCount++;
        }
      } catch (error) {
        console.error(`Station Lock/Unlock error for ${qrCode}:`, error);
        errorCount++;
      }
    }

    // Process scooter lock changes
    for (const [qrCode, newLockState] of Object.entries(scooterLockChanges)) {
      try {
        const endpoint =
          newLockState === "true" ? "/kickscooter/scooter-lock" : "/kickscooter/scooter-unlock";
        const response = await axios.post(
          `${process.env.REACT_APP_URL}${endpoint}`,
          { qrCode: qrCode },
          {
            headers: {
              "Content-Type": "application/json",
              "x-xsrf-token": userInfo.xsrfToken,
            },
            withCredentials: true,
          }
        );

        if (response.data.error === false) {
          successCount++;
        } else {
          errorCount++;
        }
      } catch (error) {
        console.error(`Scooter Lock/Unlock error for ${qrCode}:`, error);
        errorCount++;
      }
    }

    // Clear changes and refresh data
    setStationLockChanges({});
    setScooterLockChanges({});
    setHasUnsavedChanges(false);
    await getDataScooter();

    // Show result message
    if (errorCount === 0) {
      setAlertShow({
        type: "success",
        message: `Successfully updated ${successCount} lock(s)`,
      });
    } else {
      setAlertShow({
        type: "warning",
        message: `Updated ${successCount} lock(s), ${errorCount} failed`,
      });
    }
    setTimeout(() => setAlertShow({ type: "", message: "" }), 5000);
  };

  // Handle station lock state toggle (without immediate save)
  const handleStationLockToggle = (qrCode, currentState) => {
    const newState = currentState === "true" ? "false" : "true";

    // Update local display
    const updatedData = filteredData.map((item) =>
      item.qrCode === qrCode ? { ...item, station_lock_state: newState } : item
    );
    setFilteredData(updatedData);

    // Track the change
    setStationLockChanges((prev) => ({
      ...prev,
      [qrCode]: newState,
    }));
    setHasUnsavedChanges(true);
  };

  // Handle scooter lock state toggle (without immediate save)
  const handleScooterLockToggle = (qrCode, currentState) => {
    const newState = currentState === "true" ? "false" : "true";

    // Update local display
    const updatedData = filteredData.map((item) =>
      item.qrCode === qrCode ? { ...item, scooter_lock_state: newState } : item
    );
    setFilteredData(updatedData);

    // Track the change
    setScooterLockChanges((prev) => ({
      ...prev,
      [qrCode]: newState,
    }));
    setHasUnsavedChanges(true);
  };

  // Handle immediate lock/unlock (sends MQTT command instantly)
  // When button is activated (ON/true) = LOCK, when deactivated (OFF/false) = UNLOCK
  const handleInstantLockToggle = async (qrCode, currentState) => {
    const newState = currentState === "true" ? "false" : "true";
    // newState = "true" means user is activating (locking), "false" means deactivating (unlocking)
    const endpoint = newState === "true" ? "/kickscooter/lock" : "/kickscooter/unlock";
    const action = newState === "true" ? "Locking" : "Unlocking";

    try {
      // Show loading state
      setAlertShow({
        type: "info",
        message: `${action} scooter ${qrCode}...`,
      });

      const response = await axios.post(
        `${process.env.REACT_APP_URL}${endpoint}`,
        { qrCode: qrCode },
        {
          headers: {
            "Content-Type": "application/json",
            "x-xsrf-token": userInfo.xsrfToken,
          },
          withCredentials: true,
        }
      );

      if (response.data.error === false) {
        // Update local display immediately
        const updatedData = filteredData.map((item) =>
          item.qrCode === qrCode ? { ...item, lock_state: newState } : item
        );
        setFilteredData(updatedData);

        // Update main data array too
        const updatedMainData = data.map((item) =>
          item.qrCode === qrCode ? { ...item, lock_state: newState } : item
        );
        setData(updatedMainData);

        setAlertShow({
          type: "success",
          message: `✅ ${action} successful! MQTT commands sent to ESP32.`,
        });
      } else {
        setAlertShow({
          type: "error",
          message: response.data.message || `Failed to ${action.toLowerCase()} scooter`,
        });
      }
    } catch (error) {
      console.error(`Lock/Unlock error for ${qrCode}:`, error);
      setAlertShow({
        type: "error",
        message: `❌ Failed to ${action.toLowerCase()} scooter: ${error.message}`,
      });
    }

    setTimeout(() => setAlertShow({ type: "", message: "" }), 3000);
  };

  const showDialog = () => {
    setErrorDisableState(false);
    const filtredData = filteredData.filter((value) => value.checked === true);
    if (filtredData.length !== 0) {
      setOpenDialog(true);
    } else {
      setAlertShow({
        type: "error",
        message: "Please select your kickscooter",
      });
    }
  };

  useEffect(() => {
    getDataScooter();
  }, []);

  return (
    <MasterPage>
      <div className="KickScooterList">
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
        <div className="header-kickScooter">
          <div className="title-kickScooter">
            {`E-Kick Scooter list (${data.length} records)`}
          </div>
          <div className="buttons-kickScooter">
            <button className="btn-updateState" onClick={showDialog}>
              Change disable state
            </button>
            <button className="btn-exportData" onClick={exportDataToExcel}>
              <span className="icon-btn-exportData">
                <AiOutlineCloudUpload />
              </span>
              <span className="title-btn-exportData">Export excel</span>
            </button>
            <button className="btn-refresh" onClick={() => getDataScooter()}>
              <span className="icon-btn-refresh">
                <SlRefresh />
              </span>
              <span className="title-btn-refresh">Refresh</span>
            </button>
            <button
              className={`btn-save-lock-changes ${
                hasUnsavedChanges ? "has-changes" : ""
              }`}
              onClick={saveLockStateChanges}
              disabled={!hasUnsavedChanges}
              style={{
                backgroundColor: hasUnsavedChanges ? "#ADC347" : "#cccccc",
                cursor: hasUnsavedChanges ? "pointer" : "not-allowed",
                marginLeft: "10px",
                padding: "10px 20px",
                border: "none",
                borderRadius: "5px",
                color: "white",
                fontSize: "14px",
                display: "flex",
                alignItems: "center",
                gap: "8px",
                transition: "all 0.3s ease",
              }}
            >
              <span style={{ fontSize: "18px" }}>
                <MdSave />
              </span>
              <span>
                Save Lock Changes{" "}
                {hasUnsavedChanges &&
                  `(${Object.keys(stationLockChanges).length + Object.keys(scooterLockChanges).length})`}
              </span>
            </button>
          </div>
          <Dialog open={openDialog} onClose={() => setOpenDialog(false)}>
            <DialogTitle id="dialog-title">Change Disable state</DialogTitle>
            <DialogContent>
              <div className="content-dialog">
                <div className="form-group">
                  <div className="form-item">
                    <label
                      htmlFor="disable state"
                      style={{ fontSize: "18px", fontWeight: "bold" }}
                    >
                      Disable state
                    </label>

                    <FormControl
                      variant="standard"
                      sx={{ mt: 1, minWidth: 300 }}
                    >
                      <Select
                        labelId="demo-simple-select-standard-label"
                        id="demo-simple-select-standard"
                        value={disableState}
                        onChange={handleChangeSelect}
                        label="disable state"
                        style={{
                          borderBottom: "1px solid #adc347", // Change border bottom color
                        }}
                        sx={{
                          ".MuiInputBase-input": { paddingTop: "8px" },
                        }}
                      >
                        <MenuItem value={"Invisible_DS"}>Invisible</MenuItem>
                        <MenuItem value={"Lost-Forever"}>Lost-Forever</MenuItem>
                        <MenuItem value={"Repair-Not-Urgent"}>
                          Repair-Not Urgent
                        </MenuItem>
                        <MenuItem value={"Repair-Van"}>Repair-Van</MenuItem>
                        <MenuItem value={"Repair-Workshop"}>
                          Repair-Workshop
                        </MenuItem>
                        <MenuItem value={"Repair-Warehouse"}>
                          Repair-Warehouse
                        </MenuItem>
                        <MenuItem value={"Repair-Urgent"}>
                          Repair-Urgent
                        </MenuItem>
                        <MenuItem value={"Normal_DS"}>
                          Normal - Follow up
                        </MenuItem>
                      </Select>
                    </FormControl>
                    {errorDisableState ? (
                      <span
                        style={{
                          color: "red",
                          fontSize: "15px",
                          marginTop: "5px",
                        }}
                      >
                        Please select an item
                      </span>
                    ) : (
                      ""
                    )}
                  </div>
                </div>
              </div>
            </DialogContent>
            <DialogActions>
              <Button color="success" onClick={updateItem}>
                Update
              </Button>
              <Button color="success" onClick={() => setOpenDialog(false)}>
                cancel
              </Button>
            </DialogActions>
          </Dialog>
        </div>
        <div className="filter-kickscooter">
          <div className="filter-battery">
            <h4>Battery level</h4>
            <div className="checkBox">
              <input
                type="checkBox"
                value="0,15"
                checked={filtersBattery.includes("0,15")}
                name="checkbox-filter-battery"
                id="checkbox-filter"
                onChange={handleChangeBattery}
              />
              <label htmlFor="0-15%">0-15%</label>
            </div>
            <div className="checkBox">
              <input
                type="checkbox"
                value="16,50"
                checked={filtersBattery.includes("16,50")}
                name="radio-filter-battery"
                id="radio-filter"
                onChange={handleChangeBattery}
              />
              <label htmlFor="16-50%">16-50%</label>
            </div>
            <div className="checkBox">
              <input
                type="checkbox"
                value="51,100"
                checked={filtersBattery.includes("51,100")}
                name="radio-filter-battery"
                id="radio-filter"
                onChange={handleChangeBattery}
              />
              <label htmlFor="51-100%">51-100%</label>
            </div>
          </div>
          <div className="filter-visible-state">
            <h4 htmlFor="visible-state">Visible state</h4>
            <input
              type="checkbox"
              value="Invisible_VS"
              checked={filtersVisibleState.includes("Invisible_VS")}
              name="checkbox-visible-state"
              id="checkbox-filter"
              onChange={handleChangeVisibleState}
            />
            <label htmlFor="invisible">Invisible</label>
            <input
              type="checkbox"
              value="Normal_VS"
              checked={filtersVisibleState.includes("Normal_VS")}
              name="checkbox-visible-state"
              id="checkbox-filter"
              onChange={handleChangeVisibleState}
            />
            <label htmlFor="Normal">Normal</label>
          </div>
          <div className="filter-disable-state">
            <h4>Disable state</h4>
            <div className="checkbox-items">
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Invisible_DS"
                  checked={filtersDisableState.includes("Invisible_DS")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="invisible">Invisible</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Lost-Forever"
                  checked={filtersDisableState.includes("Lost-Forever")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="lost-forever">Lost-Forever</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Lost-Stolen"
                  checked={filtersDisableState.includes("Lost-Stolen")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="disable-state">Lost-Stolen</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Repair-Not-Urgent"
                  checked={filtersDisableState.includes("Repair-Not-Urgent")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="repair-not-urgent">Repair-Not Urgent</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Repair-Van"
                  checked={filtersDisableState.includes("Repair-Van")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="repair-van">Repair-Van</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Repair-Workshop"
                  checked={filtersDisableState.includes("Repair-Workshop")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="repair-workshop">Repair-Workshop</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Repair-Warehouse"
                  checked={filtersDisableState.includes("Repair-Warehouse")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="repair-warehouse">Repair-Warehouse</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Repair-Urgent"
                  checked={filtersDisableState.includes("Repair-Urgent")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="repair-urgent">Repair-Urgent</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="Normal_DS"
                  checked={filtersDisableState.includes("Normal_DS")}
                  name="checkbox-disable-state"
                  id="checkbox-filter"
                  onChange={handleChangeDisableState}
                />
                <label htmlFor="normal">Normal - Follow up</label>
              </div>
            </div>
          </div>
          <div className="buttons-filter">
            <button className="button-filter" onClick={resetTable}>
              Reset
            </button>
            <button className="button-filter" onClick={filterTable}>
              Search
            </button>
          </div>
        </div>
        <div className="main-kickscooter">
          <div className="table-wrapper">
            <div className="table-scroll">
              <table className="table-kickscooter">
                <thead>
                  <tr>
                    <th>
                      <input
                        type="checkbox"
                        className="checkbox-all"
                        onChange={handleCheckAllChange}
                        checked={filteredData.every((item) => item.checked)}
                      />
                    </th>
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
                          <th scope="row">
                            <input
                              type="checkbox"
                              className="checkbox-item"
                              checked={value.checked}
                              onChange={() =>
                                handleCheckboxChange(value.qrCode)
                              }
                            />
                            <span>{value.id}</span>
                          </th>
                          <td className="qrCode">{value.qrCode}</td>
                          <td className="visibleState">
                            {value.visible_state.split("_")[0]}
                          </td>
                          <td className="disableState">
                            {value.disable_state.split("_")[0]}
                          </td>
                          <td
                            className={`battery ${
                              value.battery <= 15
                                ? "faible"
                                : value.battery > 15 && value.battery <= 50
                                ? "medium"
                                : "high"
                            }`}
                          >{`${value.battery}%`}</td>
                          <td className="coords">{value.coords}</td>
                          <td>
                            <input
                              type="checkbox"
                              name={`stationToggle${value.id}`}
                              checked={
                                (value.station_lock_state !== undefined 
                                  ? value.station_lock_state 
                                  : value.lock_state) === "true"
                              }
                              className="mobileToggle"
                              id={`stationToggle${value.id}`}
                              onChange={() =>
                                handleStationLockToggle(
                                  value.qrCode,
                                  value.station_lock_state !== undefined 
                                    ? value.station_lock_state 
                                    : value.lock_state
                                )
                              }
                            />
                            <label htmlFor={`stationToggle${value.id}`}></label>
                          </td>
                          <td>
                            <input
                              type="checkbox"
                              name={`scooterToggle${value.id}`}
                              checked={
                                (value.scooter_lock_state !== undefined 
                                  ? value.scooter_lock_state 
                                  : value.lock_state) === "true"
                              }
                              className="mobileToggle"
                              id={`scooterToggle${value.id}`}
                              onChange={() =>
                                handleScooterLockToggle(
                                  value.qrCode,
                                  value.scooter_lock_state !== undefined 
                                    ? value.scooter_lock_state 
                                    : value.lock_state
                                )
                              }
                            />
                            <label htmlFor={`scooterToggle${value.id}`}></label>
                          </td>
                          <td>
                            <span
                              className={`status-kickscooter  ${
                                value.reserveStatus === ""
                                  ? value.scanStatus
                                  : value.reserveStatus
                              } `}
                            >
                              {value.reserveStatus === ""
                                ? value.scanStatus
                                : value.reserveStatus}
                            </span>
                          </td>
                        </tr>
                      );
                    })
                  ) : (
                    <tr>
                      <td colSpan={8}>{"No data available."}</td>
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
                count={nbrPage}
                page={currentPage}
                onChange={(event, value) => setCurrentPage(value)}
              />
            </ThemeProvider>
          </div>
        </div>
      </div>
    </MasterPage>
  );
}

export default KickScooterList;
