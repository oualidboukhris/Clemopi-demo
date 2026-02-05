-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : lun. 10 nov. 2025 à 15:00
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `clemopi_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `userId` varchar(255) DEFAULT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phoneNumber` varchar(255) DEFAULT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `age` varchar(255) DEFAULT NULL,
  `birthday` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `balance` int(11) DEFAULT NULL,
  `totalMinutes` varchar(255) DEFAULT NULL,
  `totalMeters` varchar(255) DEFAULT NULL,
  `totalOrders` varchar(255) DEFAULT NULL,
  `registerChannel` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `registerTime` varchar(255) DEFAULT NULL,
  `lastOrders` varchar(255) DEFAULT NULL,
  `lastOrderTime` varchar(255) DEFAULT NULL,
  `accountStatus` varchar(255) DEFAULT NULL,
  `unlockingWay` varchar(255) DEFAULT NULL,
  `photos` varchar(255) DEFAULT NULL,
  `deleted` varchar(25) NOT NULL,
  `createdAt` datetime NOT NULL DEFAULT current_timestamp(),
  `updatedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `clients`
--

INSERT INTO `clients` (`id`, `userId`, `username`, `email`, `phoneNumber`, `firstName`, `lastName`, `gender`, `age`, `birthday`, `region`, `balance`, `totalMinutes`, `totalMeters`, `totalOrders`, `registerChannel`, `status`, `registerTime`, `lastOrders`, `lastOrderTime`, `accountStatus`, `unlockingWay`, `photos`, `deleted`, `createdAt`, `updatedAt`) VALUES
(22, 'xTM5dHc79GdZ0vhX2wfrPwFgpxp2', 'Oualid Ha', 'oualidha1998@gmail.com', '', 'Oualid', 'Ha', '', '', '21/9/1999', '', 600, '', '', '', 'mobile', 'Enable', '13/01/2023 09:56:58', NULL, '', 'Unverified (>= 17 years old)', 'phone', NULL, 'false', '2023-01-24 16:00:43', '2023-01-24 16:00:43'),
(23, 'fLxRGDVYrIZGDnMYe1nmOKuqLA92', 'khalid khalyl', 'k.khalyl@mascir.ma', '+212 666666666', 'khalid', 'khalyl', '', '', '02/11/1998', '', 250, '', '', '', 'google', 'Enable', '19/02/2023 10:34:02', NULL, '', 'Uncommitted', 'phone', NULL, 'false', '2023-01-24 16:00:43', '2023-01-24 16:00:43'),
(25, 'cKd4dd3WRLN8fyEMrJoiWFFKhp32', 'Ay Lah', 'a.lahlalia@mascir.ma', '+212 658352636', 'Ay', 'Lah', '', '', '17/2/2000', '', 9999, '', '', '', 'mobile', 'Enable', '01/02/2023 10:34:02', '', '', 'Uncommitted', 'phone', NULL, 'false', '2023-02-19 16:51:38', '2023-02-19 16:51:38'),
(27, 'MpwPt19VsUh57sQMZEAGz636scG2', 'oualid boukhris', 'boukhris1337@gmail.com', '+212 693210198', 'oualid', 'boukhris', '', '', '22/9/1999', '', 886, '', '', '', 'email', 'Enable', '20/02/2023 09:10:58', '', '', 'Uncommitted', 'phone', NULL, 'false', '2023-02-20 05:56:59', '2023-02-20 05:56:59'),
(28, 'IsHrZoXBRDNKmejoMUAwNIcOyt62', 'Anouar Daif', 'anouar.amhache@gmail.com', '', 'Anouar', 'Daif', '', '', '', '', 2000, '', '', '', 'google', 'Enable', '20/02/2023 11:31:07', '', '', 'Uncommitted', 'phone', NULL, 'false', '2023-02-20 10:31:08', '2023-02-20 10:31:08'),
(29, 'el2ZrH5SDxbPOUxIedFnr0oryty2', 'Oualid Ha', 'oualidha1998@gmail.com', '', 'Oualid', 'Ha', '', '', '', '', 0, '', '', '', 'mobile', 'Enable', '16/03/2023 01:50:05', '', '', 'Uncommitted', 'phone', NULL, 'false', '2023-03-16 00:50:05', '2023-03-16 00:50:05'),
(30, 'Wkv5jUhRJMaBkSqATWQ71ED7Ooe2', 'ayouub mascir', 'ayoub0101@gmail.com', '+212 625178536', 'ayouub', 'mascir', '', '', '18/4/1996', '', 9999, '', '', '', 'email', 'Enable', '28/04/2023 11:35:37', '', '', 'Uncommitted', 'phone', NULL, 'false', '2023-04-28 11:35:37', '2023-04-28 11:35:37'),
(31, 'pnobccaFYIfkobizWXTrt3ErhsE2', 'Free Baum', 'freebaum.customer@gmail.com', '', 'Free', 'Baum', '', '', '', '', 9999, '', '', '', 'mobile', 'Enable', '28/04/2023 11:35:37', '', '', 'Uncommitted', 'phone', NULL, 'false', '2023-04-28 11:35:37', '2023-04-28 11:35:37'),
(32, 'Yt6ktz70uOYZOSisYLxsLAzaFGE3', 'khalid khalyl', 'khalid.khalyl@ensem.ac.ma', '+212 694827529', 'khalid', 'khalyl', '', '', '24/3/2023', '', 0, '', '', '', 'mobile', 'Enable', '28/04/2023 11:35:37', '', '', 'Uncommitted', 'phone', NULL, 'false', '2023-04-28 11:35:37', '2023-04-28 11:35:37'),
(33, 'FPSeGtTJAbSRQZAFX3wT1tNy4OK2', 'oualid boukhris', 'boukhrisoualid@gmail.com', '+212 605727894', 'oualid', 'boukhris', '', '', '22/9/1999', '', 1000, '', '', '', 'mobile', 'Enable', '05/11/2025 16:17:19', '', '', 'Uncommitted', 'phone', NULL, '', '2025-11-05 15:17:19', '2025-11-05 15:17:19'),
(34, 'xq6267ZWR7eb7l8KrdnDpyWHVII3', 'OUALID BOUKHRIS', 'boukhrisoualid@gmail.com', '', 'OUALID', 'BOUKHRIS', '', '', '', '', 0, '', '', '', 'mobile', 'Enable', '05/11/2025 16:17:19', '', '', 'Uncommitted', 'phone', NULL, '', '2025-11-05 15:17:19', '2025-11-05 15:17:19'),
(35, 'TAY54QhjklONLA54zK59SBs2j4u1', 'oualid boukhris', 'oualidha1998@gmail.com', '+212 682076736', 'oualid', 'boukhris', '', '', '12/12/2024', '', 100, '', '', '', 'mobile', 'Enable', '05/11/2025 16:17:19', '', '', 'Uncommitted', 'phone', NULL, '', '2025-11-05 15:17:19', '2025-11-05 15:17:19');

-- --------------------------------------------------------

--
-- Structure de la table `dashboard_analytics`
--

CREATE TABLE `dashboard_analytics` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `axisX` varchar(255) DEFAULT NULL,
  `verify_count` int(11) NOT NULL,
  `register_count` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT current_timestamp(),
  `updatedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `dashboard_analytics`
--

INSERT INTO `dashboard_analytics` (`id`, `name`, `axisX`, `verify_count`, `register_count`, `createdAt`, `updatedAt`) VALUES
(1, 'account', '2024-02-07 07:03:43', 2, 4, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(2, 'account', '2024-02-07 07:03:43', 3, 2, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(3, 'account', '2024-02-07 07:03:43', 4, 2, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(4, 'account', '2024-02-07 07:03:43', 6, 9, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(5, 'account', '2024-02-07 07:03:43', 3, 2, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(6, 'account', '2024-02-07 07:03:43', 7, 8, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(7, 'account', '2024-02-07 07:03:43', 1, 3, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(8, 'account', '2024-02-07 07:03:43', 3, 5, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(9, 'account', '2024-02-07 07:03:43', 4, 8, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(10, 'account', '2024-02-07 07:03:43', 6, 7, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(11, 'account', '2024-02-07 07:03:43', 5, 5, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(12, 'account', '2024-02-07 07:03:43', 3, 6, '2024-02-07 07:03:48', '2024-02-07 07:03:48'),
(13, 'payment', '2024-02-17 22:48:20', 10, 4, '2024-02-17 22:49:06', '2024-02-17 22:49:06'),
(14, 'payment', '2024-02-17 22:48:20', 3, 5, '2024-02-17 22:49:06', '2024-02-17 22:49:06'),
(15, 'payment', '2024-02-17 22:48:20', 4, 2, '2024-02-17 22:49:06', '2024-02-17 22:49:06'),
(16, 'payment', '2024-02-17 22:48:20', 6, 11, '2024-02-17 22:49:06', '2024-02-17 22:49:06'),
(17, 'payment', '2024-02-17 22:48:20', 11, 2, '2024-02-17 22:49:06', '2024-02-17 22:49:06'),
(26, 'payment', '2024-02-17 22:49:33', 3, 5, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(27, 'payment', '2024-02-17 22:49:33', 4, 2, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(28, 'payment', '2024-02-17 22:49:33', 6, 11, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(29, 'payment', '2024-02-17 22:49:33', 11, 2, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(30, 'payment', '2024-02-17 22:49:33', 5, 20, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(31, 'payment', '2024-02-17 22:49:33', 15, 10, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(32, 'payment', '2024-02-17 22:49:33', 10, 2, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(33, 'payment', '2024-02-17 22:49:33', 20, 9, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(34, 'payment', '2024-02-17 22:49:33', 22, 5, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(35, 'payment', '2024-02-17 22:49:33', 18, 5, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(36, 'payment', '2024-02-17 22:49:33', 10, 6, '2024-02-17 22:49:35', '2024-02-17 22:49:35'),
(37, 'payment', '2024-02-17 22:49:43', 10, 4, '2024-02-17 22:49:45', '2024-02-17 22:49:45'),
(38, 'payment', '2024-02-17 22:49:43', 3, 5, '2024-02-17 22:49:45', '2024-02-17 22:49:45'),
(39, 'payment', '2024-02-17 22:49:43', 4, 2, '2024-02-17 22:49:45', '2024-02-17 22:49:45'),
(40, 'payment', '2024-02-17 22:49:43', 6, 11, '2024-02-17 22:49:45', '2024-02-17 22:49:45'),
(49, 'order', '2024-02-17 22:51:42', 5, 10, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(50, 'order', '2024-02-17 22:51:42', 9, 7, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(51, 'order', '2024-02-17 22:51:42', 10, 2, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(52, 'order', '2024-02-17 22:51:42', 6, 2, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(53, 'order', '2024-02-17 22:51:42', 11, 6, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(54, 'order', '2024-02-17 22:51:42', 10, 7, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(55, 'order', '2024-02-17 22:51:42', 2, 4, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(56, 'order', '2024-02-17 22:51:42', 20, 8, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(57, 'order', '2024-02-17 22:51:42', 19, 2, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(58, 'order', '2024-02-17 22:51:42', 5, 15, '2024-02-17 22:51:46', '2024-02-17 22:51:46'),
(59, 'order', '2024-02-17 22:51:42', 8, 15, '2024-02-17 22:51:46', '2024-02-17 22:51:46');

-- --------------------------------------------------------

--
-- Structure de la table `dashboard_header`
--

CREATE TABLE `dashboard_header` (
  `id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `icon` varchar(255) NOT NULL,
  `color` varchar(255) DEFAULT NULL,
  `bgColor` varchar(255) DEFAULT NULL,
  `today` varchar(255) DEFAULT NULL,
  `total` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT current_timestamp(),
  `updatedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `dashboard_header`
--

INSERT INTO `dashboard_header` (`id`, `title`, `icon`, `color`, `bgColor`, `today`, `total`, `createdAt`, `updatedAt`) VALUES
(1, 'Order Amount', 'icon1', '#7b9310', '#e1f677', '0', '120', '2023-01-10 12:08:27', '2023-01-10 12:08:27'),
(2, 'Rides Cashflow', 'icon2', '#7b9310', '#e1f677', '1', '130', '2023-01-10 12:08:44', '2023-01-10 12:08:44'),
(3, 'Booking Cashflow', 'icon3', '#7b9310', '#e1f677', '20', '110', '2023-01-10 12:08:54', '2023-01-10 12:08:54'),
(4, 'Scooter Users', 'icon4', '#7b9310', '#e1f677', '11', '220', '2023-01-10 12:09:05', '2023-01-10 12:09:05'),
(5, 'Total meters', 'icon5', '#7b9310', '#e1f677', '12', '320', '2023-01-10 12:09:12', '2023-01-10 12:09:12');

-- --------------------------------------------------------

--
-- Structure de la table `kickscooters`
--

CREATE TABLE `kickscooters` (
  `id` int(11) NOT NULL,
  `qrCode` varchar(255) DEFAULT NULL,
  `speed` varchar(255) DEFAULT NULL,
  `head_lamp` varchar(255) DEFAULT NULL,
  `disable_state` varchar(255) DEFAULT NULL,
  `visible_state` varchar(255) DEFAULT NULL,
  `alarm_state` varchar(255) DEFAULT NULL,
  `order_state` varchar(255) DEFAULT NULL,
  `lock_state` varchar(255) DEFAULT NULL,
  `battery` varchar(255) DEFAULT NULL,
  `coords` varchar(255) DEFAULT NULL,
  `total_meters` varchar(255) DEFAULT NULL,
  `total_minutes` varchar(255) DEFAULT NULL,
  `total_amounts` varchar(255) DEFAULT NULL,
  `total_orders` varchar(255) DEFAULT NULL,
  `bleutooth_key` varchar(255) DEFAULT NULL,
  `bleutooth_password` varchar(255) DEFAULT NULL,
  `register_time` varchar(255) DEFAULT NULL,
  `communication_time` varchar(255) DEFAULT NULL,
  `authentication_code` varchar(255) DEFAULT NULL,
  `key_state` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `unlocking_way` varchar(255) DEFAULT NULL,
  `scanStatus` varchar(255) DEFAULT NULL,
  `reserveStatus` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL DEFAULT current_timestamp(),
  `updatedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `kickscooters`
--

INSERT INTO `kickscooters` (`id`, `qrCode`, `speed`, `head_lamp`, `disable_state`, `visible_state`, `alarm_state`, `order_state`, `lock_state`, `battery`, `coords`, `total_meters`, `total_minutes`, `total_amounts`, `total_orders`, `bleutooth_key`, `bleutooth_password`, `register_time`, `communication_time`, `authentication_code`, `key_state`, `region`, `unlocking_way`, `scanStatus`, `reserveStatus`, `createdAt`, `updatedAt`) VALUES
(1, 'QR198676', '230', 'on', 'Repair-Van', 'Normal_VS', 'Normal', 'Close', 'false', '12', '14.3323242,11.3423432', '2321311', '121213', '21', '15', '5bg6cfgfs3457D', '951009', '10/11/2022 11:39:45', '06/01/2023 21:20:57', '08372322423', 'Successful', 'rabat', 'gprs', '', '', '2022-12-30 15:20:23', '2022-12-30 15:20:23'),
(2, 'QR850005', '1213', 'off', 'Normal_DS', 'Normal_VS', 'Normal', 'Close', 'true', '100', '34.21432423,12.34565788', '1034323', '1', '1', '1', '8dh2ef2de245die', '32423', '17/06/2022 11:44:57', '17/06/2022 12:05:12', '97324632473243247', 'No set', 'Kenitra', 'GPRS', '', '', '2023-01-09 15:24:46', '2023-01-09 15:24:46'),
(3, 'QR792545', '1213', 'off', 'Repair-Urgent', 'Invisible_VS', 'Normal', 'Close', 'true', '50', '40.21432423,38.34565788', '1034323', '187363', '10', '30', '8dh2ef2de245die', '32423', '17/06/2022 11:44:57', '17/06/2022 12:05:12', '2134802473243247', 'No set', 'Casablanca', 'WIFI', '', '', '2023-01-09 15:26:18', '2023-01-09 15:26:18');

-- --------------------------------------------------------

--
-- Structure de la table `sequelizemeta`
--

CREATE TABLE `sequelizemeta` (
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Déchargement des données de la table `sequelizemeta`
--

INSERT INTO `sequelizemeta` (`name`) VALUES
('20221222153335-create_user_table.js'),
('20221229134230-create_kickscooters_table.js'),
('20221230142348-create_clients_table.js'),
('20230110105909-create_analytics_Dashboard_table.js'),
('20230501015908-create_header_dashboard_table.js'),
('20230502094300-create_analytics_dashboard_table.js');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(45) NOT NULL,
  `phone` varchar(45) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL DEFAULT current_timestamp(),
  `updatedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `firstName`, `lastName`, `phone`, `image_url`, `email`, `password`, `createdAt`, `updatedAt`) VALUES
(1, 'Clemopi', 'test', '212672637373', 'uploads\\1712048963493-d13eac97e1184b750a4901c832c650d1.jpg', 'clemopi@um6p.ma', '$2b$14$EyUeZgtN3rIm/Eq7LAEsr.QHr/ipyO9vNa5qYzm.Cw93/1bFdSi1q', '2023-01-10 14:39:37', '2023-01-10 14:39:37');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `dashboard_analytics`
--
ALTER TABLE `dashboard_analytics`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `dashboard_header`
--
ALTER TABLE `dashboard_header`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `kickscooters`
--
ALTER TABLE `kickscooters`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `sequelizemeta`
--
ALTER TABLE `sequelizemeta`
  ADD PRIMARY KEY (`name`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT pour la table `dashboard_analytics`
--
ALTER TABLE `dashboard_analytics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT pour la table `dashboard_header`
--
ALTER TABLE `dashboard_header`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `kickscooters`
--
ALTER TABLE `kickscooters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
