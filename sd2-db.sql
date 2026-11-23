-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Oct 30, 2022 at 09:54 AM
-- Server version: 8.0.24
-- PHP Version: 7.4.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sd2-db`
--

-- --------------------------------------------------------

--
-- Table structure for table `test_table`
--

CREATE TABLE `test_table` (
  `id` int NOT NULL,
  `name` varchar(512) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `test_table`
--

INSERT INTO `test_table` (`id`, `name`) VALUES
(1, 'Lisa'),
(2, 'Kimia');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `test_table`
--
ALTER TABLE `test_table`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `test_table`
--
ALTER TABLE `test_table`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

-- Pennywise expense tracker schema and fictional demo records
-- Safe to import more than once: tables and sample rows are created only when absent.
CREATE TABLE IF NOT EXISTS `app_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(190) NOT NULL,
  `created_at` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `expense_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `color` varchar(20) NOT NULL DEFAULT '#6f42c1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `expense_categories_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `expenses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `category_id` int NOT NULL,
  `title` varchar(160) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `spent_on` date NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `notes` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `expenses_spent_on_index` (`spent_on`),
  KEY `expenses_category_id_index` (`category_id`),
  CONSTRAINT `expenses_user_fk` FOREIGN KEY (`user_id`) REFERENCES `app_users` (`id`),
  CONSTRAINT `expenses_category_fk` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `budgets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `month_start` date NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `budgets_category_month_unique` (`category_id`,`month_start`),
  CONSTRAINT `budgets_category_fk` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `app_users` (`full_name`,`email`,`created_at`)
SELECT seed.`full_name`,seed.`email`,seed.`created_at` FROM (
  SELECT 'Aarav Mehta' AS `full_name`,'aarav@example.com' AS `email`,DATE('2026-01-05') AS `created_at` UNION ALL
  SELECT 'Maya Patel','maya@example.com',DATE('2026-01-12') UNION ALL
  SELECT 'Rohan Shah','rohan@example.com',DATE('2026-02-02') UNION ALL
  SELECT 'Anika Rao','anika@example.com',DATE('2026-02-14') UNION ALL
  SELECT 'Kabir Das','kabir@example.com',DATE('2026-03-01')
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM `app_users`);

INSERT INTO `expense_categories` (`name`,`color`)
SELECT seed.`name`,seed.`color` FROM (
  SELECT 'Food' AS `name`,'#f59e0b' AS `color` UNION ALL
  SELECT 'Transport','#0ea5e9' UNION ALL
  SELECT 'Housing','#8b5cf6' UNION ALL
  SELECT 'Utilities','#14b8a6' UNION ALL
  SELECT 'Entertainment','#ec4899'
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM `expense_categories`);

INSERT INTO `expenses` (`user_id`,`category_id`,`title`,`amount`,`spent_on`,`payment_method`,`notes`)
SELECT seed.`user_id`,seed.`category_id`,seed.`title`,seed.`amount`,seed.`spent_on`,seed.`payment_method`,seed.`notes`
FROM (
  SELECT 1 AS `user_id`,1 AS `category_id`,'Weekly groceries' AS `title`,2450.00 AS `amount`,CURRENT_DATE - INTERVAL 1 DAY AS `spent_on`,'Card' AS `payment_method`,'Groceries and pantry items' AS `notes` UNION ALL
  SELECT 2,2,'Metro pass',1200.00,CURRENT_DATE - INTERVAL 3 DAY,'UPI','Monthly commute' UNION ALL
  SELECT 3,3,'Shared rent',18000.00,CURRENT_DATE - INTERVAL 5 DAY,'Bank transfer','Apartment rent' UNION ALL
  SELECT 4,4,'Electricity bill',1840.50,CURRENT_DATE - INTERVAL 8 DAY,'UPI','Monthly electricity' UNION ALL
  SELECT 5,5,'Cinema evening',950.00,CURRENT_DATE - INTERVAL 12 DAY,'Card','Tickets and snacks'
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM `expenses`);

INSERT INTO `budgets` (`category_id`,`month_start`,`amount`)
SELECT seed.`category_id`,DATE_FORMAT(CURRENT_DATE,'%Y-%m-01'),seed.`amount` FROM (
  SELECT 1 AS `category_id`,10000.00 AS `amount` UNION ALL
  SELECT 2,5000.00 UNION ALL
  SELECT 3,22000.00 UNION ALL
  SELECT 4,4000.00 UNION ALL
  SELECT 5,3500.00
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM `budgets` WHERE `month_start`=DATE_FORMAT(CURRENT_DATE,'%Y-%m-01'));

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
