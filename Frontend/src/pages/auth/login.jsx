import React, {  useEffect, useState } from "react";
import "./login.scss";
import LogoImage from "../../img/logo.png";
import backImage from "../../img/banner_profil2.png";
import { Alert, CircularProgress } from "@mui/material";
import { MdError } from "react-icons/md";
import {  useNavigate } from "react-router-dom";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import axios from "axios";
import { useDispatch,useSelector } from "react-redux";
import { setCredentials } from "../../hooks/authSlice";






function Login() {

  const navigate = useNavigate();
  const dispatch = useDispatch();
  const {userInfo} = useSelector((state) => state.auth)
  const [username, setUsername] = useState(null);
  const [password, setPassword] = useState(null);
  const [loading, setLoading] = useState(false);
  const [errorMessageUsername, setErrorMessageUsername] = useState(null);
  const [errorMessagePassword, setErrorMessagePassword] = useState(null);
  const [errorValidation, setErrorValidation] = useState(null);
  const [validationMessage, setValidationMessage] = useState(null); 
  const emailReg =
    /[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]/g;
 
  function validation(value, type) {
    if (type === "invalid-username") {
      if (value === "" || value === null) {
        return setErrorMessageUsername("Please enter your email address");
      } else if (!value.match(emailReg)) {
        return setErrorMessageUsername("Please enter a valid email address");
      }
      setErrorMessageUsername(null);
      return true;
    } else {
      if (value === "" || value === null) {
        return setErrorMessagePassword("Please enter your password");
      } else if (value.length < 4 && value.length < 20) {
        return setErrorMessagePassword(
          "Your password must contain between 4 and 20 characters."
        );
      }
      setErrorMessagePassword(null);
      return true;
    }
  }

  const login = async (e) => {
    if (e.type === "click" || e.key === "Enter") {
      const validationEmail = validation(username, "invalid-username");
      const validationPassword = validation(password, "invalid-password");
      if (validationEmail === true && validationPassword === true) {
        setLoading(true);
        axios.post(
            `${process.env.REACT_APP_URL}/login`,
            { username: username, password: password },
          )
          .then((res) => {
            setLoading(false);
          //  signIn({
          //     token:res.data.xsrfToken,
          //     expiresIn: 1440,
          //     authState: { email: username },
          //     tokenType:"Bearer"
          //   });          
          //update the auth context
          dispatch(setCredentials({...res.data}))
          navigate("/dashboard");
          })
          .catch((err) => {
            setLoading(false);
            if (err.response.data.error === true) {
              setErrorValidation(true);
            }
          });

        //-----------------------firebase signIn-----------------------

        // const auth = getAuth();
        // signInWithEmailAndPassword(auth, username, password)
        //   .then((userCredential) => {
        //     const user = userCredential.user;
        //     signIn({
        //       token:user.accessToken,
        //       expiresIn: 1440,
        //       authState: { email: username },
        //       tokenType:"Bearer"
        //     });
        //     navigate("/dashboard");
        //   })
        //   .catch((error) => {
        //     setLoading(false);
        //     setErrorValidation(true);
            
        //   });
      }
    }
  };

  useEffect(() => {
    if(userInfo){
      navigate("/dashboard");
    }
  }, [navigate,userInfo])
  

  return (
    
    <div className="Login"> 
      {errorValidation && (
        <Alert
          onClose={() => {
            setErrorValidation(false);
          }}
          icon={<MdError fontSize="inherit" />}
          sx={{
            position: "absolute",
            right: "0",
            margin: 2,
          }}
          variant="filled"
          severity="error"
        >
          Username or Password incorrect.
        </Alert>
      )}

      <div
        id="bg-overlay"
        className="bg__img"
        style={{ backgroundImage: `url(${backImage})` }}
      ></div>
      <form className="form__login">
        <div className="logo__image">
          <img src={LogoImage} alt="Logo not found" />
        </div>
        <div className="inputs">
          <div className="input-group">
            <label htmlFor="email">Email</label>

            <input
              autoComplete="off"
              type="text"
              name="email-input"
              id="email"
              className={`input-item ${
                errorMessageUsername === null ? "" : "invalid"
              }`}
              onChange={(e) => setUsername(e.currentTarget.value)}
              onKeyUp={login}
            />
            {errorMessageUsername === null ? (
              ""
            ) : (
              <span className="ValidationForm">{errorMessageUsername}</span>
            )}
          </div>
          <div className="input-group">
            <label htmlFor="email">Password</label>
            <input
              autoComplete="off"
              type="password"
              name="password-input"
              id="password"
              className={`input-item ${
                errorMessagePassword === null ? "" : "invalid"
              }`}
              onChange={(e) => setPassword(e.currentTarget.value)}
              onKeyUp={login}
            />
            {errorMessagePassword === null ? (
              ""
            ) : (
              <span className="ValidationForm">{errorMessagePassword}</span>
            )}
          </div>

          <div className="input__checkbox">
            <input type="checkbox" name="input-remember" id="rememberMe" />
            <label htmlFor="remember">Remember me</label>
          </div>
          <button type="button" value="Sign in" onClick={login}>
            {loading ? (
              <CircularProgress
                size={30}
                sx={{
                  color: "white",
                  position: "absolute",
                  top: 3,
                  left: 110,
                  zIndex: 1,
                }}
              />
            ) : (
              "Sign in"
            )}
          </button>
        </div>
      </form>
    </div>
  );
}

export default Login;
