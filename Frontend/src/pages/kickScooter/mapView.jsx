import { GoogleMap, MarkerF, useLoadScript } from "@react-google-maps/api";
import React from "react";
import MasterPage from "../../components/masterPage/masterPage";
import "./mapView.scss";
import { RiQuestionMark } from "react-icons/ri";
import { Avatar } from "@mui/material";
import { useState } from "react";
import { ref, onValue } from "firebase/database";
import { rltm } from "../../firebase";
import { useEffect } from "react";
import { GiConsoleController } from "react-icons/gi";

function MapView() {
  const [markers, setMarkers] = useState({});
 // const userInfo = useSelector((state)=>state.auth);
  const { isLoaded } = useLoadScript({
    googleMapsApiKey: process.env.REACT_APP_GOOGLE_MAPS_KEY,
  });

  const getDataGPS = async () => {
    try {
      //  while (hasData) {
      //for (let scooterIndex = 1; scooterIndex <= 3; scooterIndex++) {
        // const paddedNumber =
        //   scooterIndex < 10 ? `0${scooterIndex}` : `${scooterIndex}`;
    
        const databaseRef = ref(rltm, `Scooter01/gpsData`);
        onValue(databaseRef, (snapshot) => {
          const data = snapshot.val();
          console.log('oualid')
          console.log(data)
            setMarkers(data);
        });
   //  }

      //  }
    } catch (error) {
      console.error("Error fetching data:", error);
    }
  };

  useEffect(() => {
    getDataGPS();
    return () => setMarkers([]);
  }, []);

  return (
    <MasterPage>
      <div className="map-view">
        <div className="header-map">
          <div className="filter-kickscooter">
            <div className="filter-battery">
              <h4>Battery level</h4>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="0-15"
                  name="checkbox-filter-battery"
                  id="checkbox-filter"
                />
                <label htmlFor="invisible">0-15%</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="16-50"
                  name="checkbox-filter-battery"
                  id="checkbox-filter"
                />
                <label htmlFor="invisible">16-50%</label>
              </div>
              <div className="checkbox">
                <input
                  type="checkbox"
                  value="51-100"
                  name="checkbox-filter-battery"
                  id="checkbox-filter"
                />
                <label htmlFor="invisible">51-100%</label>
              </div>
            </div>
            <div className="filter-visible-state">
              <h4 htmlFor="visible-state">Visible state</h4>
              <input
                type="checkbox"
                value="Invisible"
                name="checkbox-visible-state"
                id="checkbox-filter"
              />
              <label htmlFor="invisible">Invisible</label>
              <input
                type="checkbox"
                value="Normal"
                name="checkbox-visible-state"
                id="checkbox-filter"
              />
              <label htmlFor="Normal">Normal</label>
            </div>
            <div className="filter-disable-state">
              <h4>Disable state</h4>
              <div className="checkbox-items">
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Invisible"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="invisible">Invisible</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Lost-Forever"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="lost-forever">Lost-Forever</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Lost-Stolen"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="disable-state">Lost-Stolen</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Repair-Not-Urgent"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="repair-not-urgent">Repair-Not Urgent</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Repair-Van"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="repair-van">Repair-Van</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Repair-Workshop"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="repair-workshop">Repair-Workshop</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Repair-Warehouse"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="repair-warehouse">Repair-Warehouse</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Repair-Urgent"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="repair-urgent">Repair-Urgent</label>
                </div>
                <div className="checkbox">
                  <input
                    type="checkbox"
                    value="Normal"
                    name="checkbox-disable-state"
                    id="checkbox-filter"
                  />
                  <label htmlFor="normal">Normal - Follow up</label>
                </div>
              </div>
            </div>
            <div className="filter-icon-color">
              <h4 htmlFor="icon-color">Icon color</h4>
              <div className="radio-btn">
                <input
                  type="radio"
                  value="byBattery"
                  name="radio-icon-color"
                  id="checkbox-filter"
                  defaultChecked="true"
                />
                <label htmlFor="byBattery">By battery</label>
              </div>
              <div className="radio-btn">
                <input
                  type="radio"
                  value="orderTime"
                  name="radio-icon-color"
                  id="checkbox-filter"
                />
                <label htmlFor="orderTime">By last order time</label>
              </div>

              <div className="radio-btn">
                <input
                  type="radio"
                  value="hideColor"
                  name="radio-icon-color"
                  id="checkbox-filter"
                />
                <label htmlFor="hideColor">hide color</label>
              </div>
            </div>
            <div className="buttons-filter">
              <button className="button-filter">Reset</button>
              <button className="button-filter">Search</button>
            </div>
          </div>
        </div>
        <div className="panel-map-view">
          <div className="panel-control-map-view">
            <div className="panel-title">
              <h3>Kick-scooter search result</h3>
            </div>
            <div className="show-region-mark">
              <input type="checkbox" name="show-region-mark" />
              <label htmlFor="show_region_mark">
                show the last reported position of vehicle
              </label>
            </div>
            <div className="color-tips">
              <Avatar
                sx={{
                  bgcolor: "#ADC347",
                  cursor: "pointer",
                  "&:hover": { bgcolor: "#7b9310" },
                }}
              >
                <RiQuestionMark />
              </Avatar>
            </div>
          </div>
          <div>
          
          </div>
          <div className="panel-body">
            {isLoaded === false ? (
              <div>Loading ...</div>
            ) : (
              <GoogleMap
                mapContainerStyle={{ height: "600px", width: "100%" }}
                center={{ lat: 32.21627, lng: -7.93372 }}
                zoom={17}
              >
               
                    <MarkerF
                    position={{ lat: markers.lat, lng: markers.long}}/>

           
              </GoogleMap>
            )}
          </div>
        </div>
      </div>
    </MasterPage>
  );
}

export default MapView;
