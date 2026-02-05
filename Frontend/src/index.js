import React from 'react';

import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css'
import './pages/auth/login.scss'
import reportWebVitals from './reportWebVitals';
import { Provider } from 'react-redux';
import store  from './store'
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <Provider store = {store}>
    
          <React.StrictMode>
          {/* <AuthProvider
              authType={"cookie"}
              authName={"_auth"}
              cookieDomain={window.location.hostname}
              cookieSecure={window.location.protocol === "https:"}
            > */}
            
                <App />
            
          
          {/* </AuthProvider> */}
        </React.StrictMode>
     
  </Provider>
  
);

reportWebVitals();