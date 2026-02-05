import Login from "./pages/auth/login";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import KickScooterList from "./pages/kickScooter/kickScooterList";
import KickScooter from "./pages/kickScooter/kickScooter";
import MapView from "./pages/kickScooter/mapView";
import UserList from "./pages/user/userList";
import User from "./pages/user/user";
import OrderList from "./pages/kickScooter/orderList";
import Dashboard from "./pages/dashboard/dashboard";
import { RequireAuth, useIsAuthenticated } from "react-auth-kit";
import { useEffect } from "react";
import PrivateRoute from "./PrivateRoute";
import Settings from "./pages/settings/settings";

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Login />} />
          <Route path="" element={<PrivateRoute />}>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/kick-scooters" element={<KickScooterList />} />
            <Route path="/kick-scooter" element={<KickScooter />} />
            <Route path="/map-view" element={<MapView />} />
            <Route path="/users" element={<UserList />} />
            <Route path="/user" element={<User />} />
            <Route path="/order-list" element={<OrderList />} />
            <Route path="/settings" element={<Settings />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
