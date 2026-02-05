import React, { useEffect } from "react";
import MasterPage from "../../components/masterPage/masterPage";
import "./dashboard.scss";
import { MdOutlineStorage } from "react-icons/md";
import { GiKickScooter } from "react-icons/gi";
import { TbListCheck } from "react-icons/tb";
import { BsCoin } from "react-icons/bs";
import { TbDeviceAnalytics } from "react-icons/tb";
import { Avatar, Box, Tab } from "@mui/material";
import TabList from '@mui/lab/TabList';
import TabPanel from '@mui/lab/TabPanel';
import TabContext from '@mui/lab/TabContext';
import Piechart from "../../components/chart/pieChart";
import AreaLine from "../../components/chart/areaChart";
import BarChart from "../../components/chart/barChart";
import { useState } from "react";
import axios from "axios";
import { useSelector } from "react-redux";


const headerDashboard = [
  {
    title: "Order Amount",
    icon: "icon1",
    color: "#7b9310",
    bgcolor: "#e1f677",
    today: "0",
    total: "120",
  },
  {
    title: "Rides Cashflow",
    icon: "icon2",
    color: "#7b9310",
    bgcolor: "#e1f677",
    today: "0",
    total: "120",
  },
  {
    title: "Booking Cashflow",
    icon: "icon3",
    color: "#7b9310",
    bgcolor: "#e1f677",
    today: "10",
    total: "120",
  },
  {
    title: "Scooter Users",
    icon: "icon4",
    color: "#7b9310",
    bgcolor: "#e1f677",
    today: "12",
    total: "53",
  },
  {
    title: "Total meters",
    icon: "icon5",
    color: "#7b9310",
    bgcolor: "#e1f677",
    today: "3",
    total: "130",
  },
];

axios.defaults.withCredentials = true;

function Dashboard() {
  const [value, setValue] = useState(0);
  const [dataHeaderAnalytics, setDataHeaderAnalytics] = useState([]);
  const [dataAreaChartAccount, setDataAreaChartAccount] = useState([]);
  const [dataPieChartAccount, setdataPieChartAccount] = useState([]);
  const {userInfo} = useSelector((state)=>state.auth);
  const [tabsValue, setTabsValue] = useState("1");

  const handleChange = (event, newValue) => {
    setValue(newValue);
  };
  
  const handleChangeTabs = (event, newValue) => {
    if(newValue === "1"){
      getDataAnalyticsAccount("account");
    }else if(newValue === "2"){
      console.log("oualid")
      getDataAnalyticsAccount("order");
    }else if(newValue === "3") {
      getDataAnalyticsAccount("payment");
    }
    setTabsValue(newValue);    
  };

  const getDataAnalyticsHeader = async (qrCode) => {
    await axios
      .get(`${process.env.REACT_APP_URL}/dataAnalyticsHeader`, {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
        withCredentials: true,
      })
      .then((res) => {
        setDataHeaderAnalytics(res.data);
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const getDataAnalyticsAccount = async (type) => {
    await axios
      .get(`${process.env.REACT_APP_URL}/dataAnalyticsAccount/${type}`, {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
        withCredentials: true,
      })
      .then((res) => {
        setDataAreaChartAccount(res.data.areaChart);
        setdataPieChartAccount(res.data.pieChart);
      })
      .catch((err) => {
        console.log(err);
      });
  };

  useEffect(() => {
    getDataAnalyticsHeader();
    getDataAnalyticsAccount("account");
  }, []);

  return (
    <MasterPage>
      <div className="Dashboard">
        <div className="title-chart">
          <h3>
            <span>
              <TbDeviceAnalytics />
            </span>
            <span>Analytics Dashboard</span>
          </h3>
        </div>
        {/* <div className="dashboard-header">
          <div className="dashboard-card">
            <div className="header-card">
              <span>
                <Avatar sx={{ bgcolor: "#e1f677" }}>
                  <MdOutlineStorage color={"#7b9310"} />
                </Avatar>
              </span>

              <span>Order Amount</span>
            </div>
            <div className="content-card">
              <div className="statistic-title">
                <span>Today</span>
                <span>Total</span>
              </div>
              <div className="statistic-number">
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[0].today}
                </span>
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[0].total}
                </span>
              </div>
            </div>
          </div>
          <div className="dashboard-card">
            <div className="header-card">
              <span>
                <Avatar sx={{ bgcolor: "#e1f677" }}>
                  <BsCoin color={"#7b9310"} />
                </Avatar>
              </span>

              <span>Rides Cashflow</span>
            </div>
            <div className="content-card">
              <div className="statistic-title">
                <span>Today</span>
                <span>Total</span>
              </div>
              <div className="statistic-number">
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[1].today}
                </span>
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[1].total}
                </span>
              </div>
            </div>
          </div>
          <div className="dashboard-card">
            <div className="header-card">
              <span>
                <Avatar sx={{ bgcolor: "#e1f677" }}>
                  <BsCoin color={"#7b9310"} />
                </Avatar>
              </span>

              <span>Booking Cashflow</span>
            </div>
            <div className="content-card">
              <div className="statistic-title">
                <span>Today</span>
                <span>Total</span>
              </div>
              <div className="statistic-number">
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[2].today}
                </span>
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[2].total}
                </span>
              </div>
            </div>
          </div>
          <div className="dashboard-card">
            <div className="header-card">
              <span>
                <Avatar sx={{ bgcolor: "#e1f677" }}>
                  <GiKickScooter color={"#7b9310"} />
                </Avatar>
              </span>

              <span>Scooter Users</span>
            </div>
            <div className="content-card">
              <div className="statistic-title">
                <span>Today</span>
                <span>Total</span>
              </div>
              <div className="statistic-number">
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[3].today}
                </span>
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[3].total}
                </span>
              </div>
            </div>
          </div>
          <div className="dashboard-card">
            <div className="header-card">
              <span>
                <Avatar sx={{ bgcolor: "#e1f677" }}>
                  <TbListCheck color={"#7b9310"} />
                </Avatar>
              </span>

              <span>Total meters</span>
            </div>
            <div className="content-card">
              <div className="statistic-title">
                <span>Today</span>
                <span>Total</span>
              </div>
              <div className="statistic-number">
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[4].today}
                </span>
                <span>
                  {!dataHeaderAnalytics ? "0" : dataHeaderAnalytics[4].total}
                </span>
              </div>
            </div>
          </div>
        </div> */}
        <div className="dashboard-header">
          {dataHeaderAnalytics.map((value) => {
            return (
              <div className="dashboard-card" key={value.title}>
                <div className="header-card">
                  <span>
                    <Avatar sx={{ bgcolor: value.bgColor }}>
                      {value.icon === "icon1" ? (
                        <MdOutlineStorage color={value.color} />
                      ) : value.icon === "icon2" ? (
                        <BsCoin color={value.color} />
                      ) : value.icon === "icon3" ? (
                        <BsCoin color={value.color} />
                      ) : value.icon === "icon4" ? (
                        <GiKickScooter color={value.color} />
                      ) : (
                        <TbListCheck color={value.color} />
                      )}
                    </Avatar>
                  </span>

                  <span>{value.title}</span>
                </div>
                <div className="content-card">
                  <div className="statistic-title">
                    <span>Today</span>
                    <span>Total</span>
                  </div>
                  <div className="statistic-number">
                    <span>{value.today}</span>
                    <span>{value.total}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
        <div className="dashboard-body">
          <div className="card-chart">
            <div className="card-body">
            <TabContext value={tabsValue}>
              <Box sx={{ width: "100%" }}>
                <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
                  <TabList
                    onChange={handleChangeTabs}
                    TabIndicatorProps={{
                      style: {
                        backgroundColor: "#ADC347",
                      },
                    }}
                    sx={{ "& button.Mui-selected": { color: "#ADC347" } }}
                  >
                    <Tab label="Account" value="1" />
                    <Tab label="Order" value="2" />
                    <Tab label="Payment" value="3" />
                  </TabList>
                  {/* <Tabs
                    value={value}
                    onChange={handleChange}
                    TabIndicatorProps={{
                      style: {
                        backgroundColor: "#ADC347",
                      },
                    }}
                    sx={{ "& button.Mui-selected": { color: "#ADC347" } }}
                  >
                    <Tab label="Account" {...a11yProps(0)} />
                    <Tab label="Order" {...a11yProps(1)} />
                    <Tab label="Payment" {...a11yProps(2)} />
                  </Tabs> */}
                </Box>
                <TabPanel  value="1" sx={{p:0}} >
                  <div className="chart-wrapper">
                    <AreaLine data={dataAreaChartAccount} />
                    <Piechart
                      descriptionTitle1="Verify"
                      descriptionTitle2="Register"
                      data={dataPieChartAccount}
                    />
                  </div>
                  <div className="chart-bar">
                    <BarChart data={dataAreaChartAccount} />
                  </div>
                </TabPanel>
                <TabPanel  value="2" sx={{p:0}}>
                  <div className="chart-wrapper">
                    <AreaLine data={dataAreaChartAccount} />
                    <Piechart
                      descriptionTitle1="Verify"
                      descriptionTitle2="Register"
                      data={dataPieChartAccount}
                    />
                  </div>
                  <div className="chart-bar">
                    <BarChart data={dataAreaChartAccount} />
                  </div>
                </TabPanel>
                <TabPanel value="3" sx={{p:0}}>
                  <div className="chart-wrapper">
                    <AreaLine data={dataAreaChartAccount} />
                    <Piechart
                      descriptionTitle1="Verify"
                      descriptionTitle2="Register"
                      data={dataPieChartAccount}
                    />
                  </div>
                  <div className="chart-bar">
                    <BarChart data={dataAreaChartAccount} />
                  </div>
                </TabPanel>
              </Box>
              </TabContext>
            </div>
          </div>
        </div>
      </div>
    </MasterPage>
  );
}

export default Dashboard;
