import { React, useEffect, useState } from "react";
import { styled } from "@mui/material/styles";
import Box from "@mui/material/Box";
import MuiDrawer from "@mui/material/Drawer";
import MuiAppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import Menu from "@mui/material/Menu";
import List from "@mui/material/List";
import CssBaseline from "@mui/material/CssBaseline";
import Divider from "@mui/material/Divider";
import IconButton from "@mui/material/IconButton";
import BackgroundImage from "../../img/bg_01.png";
import LogoImage from "../../img/logo.png";
import { AiOutlineMenu } from "react-icons/ai";
import sidebarItem from "../../sidebar.json";
import SideBar from "./sidebar";
import "./masterPage.scss";
import { Avatar, Badge, Drawer, ListItemIcon, MenuItem, Tooltip, Typography } from "@mui/material";
import { AiOutlineSetting } from "react-icons/ai";
import { IoLogOutOutline } from "react-icons/io5";
import { BsFillBellFill } from "react-icons/bs";
import imgProfil from "../../img/logo.png";
import { Navigate, useNavigate } from "react-router-dom";
import axios from "axios";
import { useDispatch, useSelector } from "react-redux";
import { logout } from "../../hooks/authSlice";

const drawerWidth = 240;


const AppBar = styled(MuiAppBar, {
  shouldForwardProp: (prop) => prop !== "open",
})(({ theme, open }) => ({
  zIndex: theme.zIndex.drawer + 1,
  transition: theme.transitions.create(["width", "margin"], {
    easing: theme.transitions.easing.sharp,
    duration: theme.transitions.duration.leavingScreen,
  }),
  ...(open && {
    marginLeft: drawerWidth,
    width: `calc(100% - ${drawerWidth}px)`,
    transition: theme.transitions.create(["width", "margin"], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.enteringScreen,
    }),
  }),
}));





export default function MasterPage(props) {
  const { window } = props;
  const [mobileOpen, setMobileOpen] = useState(false);
  const [isClosing, setIsClosing] = useState(false);

  const handleDrawerClose = () => {
    setIsClosing(true);
    setMobileOpen(false);
  };

  const handleDrawerTransitionEnd = () => {
    setIsClosing(false);
  };

  const handleDrawerToggle = () => {
    if (!isClosing) {
      setMobileOpen(!mobileOpen);
    }
  };
  const [anchorEl, setAnchorEl] = useState(null);
  const [imageUrl, setImageUrl] = useState()
  const { userInfo } = useSelector((state) => state.auth);
  const dispatch = useDispatch();
  const userId = userInfo.xsrfToken.split("%")[1];
  const openMenu = Boolean(anchorEl);
  const navigate = useNavigate();
  const [dataUserValues, setDataUserValues] = useState({
    firstName: "",
    lastName: "",
    image_url: "",
  });

  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };
  const handleClose = () => {
    setAnchorEl(null);
  };

  const handlingSignOut = async () => {
    await axios.post(
      `${process.env.REACT_APP_URL}/logout`,
    ).then((res) => {
      dispatch(logout());
    });
    navigate("/", { replace: true });
  }

  const getDataUser = async () => {
    try {
      const response = await axios.get(`${process.env.REACT_APP_URL}/users/${userId}`, {
        headers: {
          "x-xsrf-token": userInfo.xsrfToken,
        },
      });
      setDataUserValues({
        firstName: response.data.firstName,
        lastName: response.data.lastName,
        image_url: response.data.image_url,
      })
      setImageUrl(response.data.image_url)
    } catch (error) {
      console.error('Error uploading file:', error);
    }
  }

  useEffect(() => {
    getDataUser()
  }, [])

  const drawer = (
    <div>
      <Box
        component="img"
        marginLeft={4}
        sx={{
          width: 150,
        }}
        alt="logo image not found"
        src={LogoImage}
      />

      <Divider />
      <List>
        {sidebarItem.map((value, index) => {
          return <SideBar key={index} item={value} isOpen={mobileOpen} />;
        })}
      </List>
    </div>
  );
  const container = window !== undefined ? () => window().document.body : undefined;
  return (
    <Box sx={{ display: "flex" }}>
      <CssBaseline />
      <AppBar position="fixed" style={{ background: "#191A1A" }} sx={{
        width: { sm: `calc(100% - ${drawerWidth}px)` },
        ml: { sm: `${drawerWidth}px` },
      }}>
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            textAlign: "center",
            flexDirection: "row",
            justifyContent: "space-between",
          }}
        >
          <Toolbar>
            <IconButton
              color="inherit"
              aria-label="open drawer"
              onClick={handleDrawerToggle}
              edge="start"
              sx={{
                marginRight: 5,
                display: { sm: 'none' }
              }}
            >
              <AiOutlineMenu />
            </IconButton>
          </Toolbar>
          <Box
            component="div"
            sx={{ marginRight: 2, display: "flex", alignItems: "center" }}
          >
            <Box component="div" sx={{ marginRight: 4, cursor: "pointer" }}>
              <Badge
                badgeContent={0}
                sx={{
                  "& .MuiBadge-badge": {
                    backgroundColor: "#ED4C67",
                    fontWeight: "bold",
                  },
                }}
              >
                <BsFillBellFill color="#ffffff" size={20} />
              </Badge>
            </Box>
            <Tooltip title="Clemopi">
              <Avatar
                sx={{ width: 38, height: 38, bgcolor: "black", cursor: "pointer" }}
                onClick={handleClick}
                src={imageUrl && `${process.env.REACT_APP_URL_IMAGE}/${imageUrl}`}
                aria-controls={openMenu ? 'account-menu' : undefined}
                aria-haspopup="true"
                aria-expanded={openMenu ? 'true' : undefined}
              >
              </Avatar>
            </Tooltip>
          </Box>
        </Box>
        <Menu
          anchorEl={anchorEl}
          id="account-menu"
          open={openMenu}
          onClose={handleClose}
          onClick={handleClose}
          PaperProps={{
            elevation: 0,
            sx: {
              overflow: "visible",
              filter: "drop-shadow(0px 2px 8px rgba(0,0,0,0.32))",
              mt: 1.5,
              "& .MuiAvatar-root": {
                width: 32,
                height: 32,
                ml: -0.5,
                mr: 1,
              },
              "&:before": {
                content: '""',
                display: "block",
                position: "absolute",
                top: 0,
                right: 14,
                width: 10,
                height: 10,
                bgcolor: "background.paper",
                transform: "translateY(-50%) rotate(45deg)",
                zIndex: 0,
              },
            },
          }}
          transformOrigin={{ horizontal: "right", vertical: "top" }}
          anchorOrigin={{ horizontal: "right", vertical: "bottom" }}
        >
          <MenuItem>
            <Avatar src={imageUrl && `${process.env.REACT_APP_URL_IMAGE}/${imageUrl}`} sx={{ bgcolor: "#191A1A" }} />
            {dataUserValues.firstName + " " + dataUserValues.lastName}
          </MenuItem>
          <Divider />

          <MenuItem onClick={() => navigate("/settings")}>
            <ListItemIcon>
              <AiOutlineSetting size={22} color="#191A1A" />
            </ListItemIcon>
            Settings
          </MenuItem>
          <MenuItem onClick={handlingSignOut}>
            <ListItemIcon>
              <IoLogOutOutline size={22} color="#191A1A" />
            </ListItemIcon>
            Logout
          </MenuItem>
        </Menu>
      </AppBar>

      <Box
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
       
      >
        <Drawer
          variant="temporary"
          container={container}
          open={mobileOpen}
          onTransitionEnd={handleDrawerTransitionEnd}
          onClose={handleDrawerClose}
          ModalProps={{
            keepMounted: true, // Better open performance on mobile.
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          PaperProps={{
            sx: {

              backgroundImage: `url(${BackgroundImage})`,
              backgroundRepeat: "no-repeat",
              backgroundPosition: "center center",
              backgroundSize: "cover",
            },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          PaperProps={{
            sx: {
              backgroundImage: `url(${BackgroundImage})`,
              backgroundRepeat: "no-repeat",
              backgroundPosition: "center center",
              backgroundSize: "cover",
            },
          }}
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>

      </Box>

      <Box component="main" 
        sx={{ flexGrow: 1, p: 3, width: { sm: `calc(100% - ${drawerWidth}px)` } }}>
          {props.children} 
      </Box>
    </Box>
  );
}

