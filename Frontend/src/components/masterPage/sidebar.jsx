import { Menu } from "@mui/material";
import React, { useEffect } from "react";
import { AiOutlineDashboard, AiOutlineUser } from "react-icons/ai";
import { GiKickScooter } from "react-icons/gi";
import { MdKeyboardArrowRight, MdKeyboardArrowDown } from "react-icons/md";
import { Link } from "react-router-dom";
import Fade from "@mui/material/Fade";
import { useNavigate } from "react-router-dom";

function SideBar(props) {
  const [openMenu, setOpenMenu] = React.useState(false);
  const [active, setActive] = React.useState(null);
  const [anchorEl, setAnchorEl] = React.useState(null);
  const open = Boolean(anchorEl);
  const navigate = useNavigate();
  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };
  const handleClose = () => {
    setAnchorEl(null);
  };
  
  return (
    <div className="dropdown-menu">
      
      <li
        className="list-item"
        onClick={
       props.item.icon === "AiOutlineDashboard"
            ? () => {
                navigate("/dashboard");
              }
            : () => {
                setOpenMenu(!openMenu);
              }
        }
      >
       
        <div className="content-list-item">
          <div className="icon-list-item">
            {props.item.icon === "AiOutlineDashboard" ? (
              <AiOutlineDashboard />
            ) : props.item.icon === "GiKickScooter" ? (
              <GiKickScooter />
            ) : (
              <AiOutlineUser />
            )}
          </div>
          <div className="text-list-item">
            {
                props.item.title
            }
          </div>
        </div>
        {props.item.icon === "AiOutlineDashboard" ? (
          ""
        ) : (
          <div className="icon-menu-list-item">
            {openMenu === false ? (
              <MdKeyboardArrowRight />
            ) : (
              <MdKeyboardArrowDown />
            )}
          </div>
        )}
      </li>
      
        <ul className={`menu-item open ${openMenu === false ? "" : "show"}`}>
          {props.item.childrens.map((value, index) => {
            return (
              <Link
                to={value.url}
                className="menu-item-link"
                key={index}
                onClick={() => setActive(value)}
              >
                <li
                  className={`menu-item-title ${
                    active === value ? "selected" : ""
                  }`}
                >
                  {value.title}
                </li>
              </Link>
            );
          })}
        </ul>    
    </div>
  );
}

export default SideBar;
