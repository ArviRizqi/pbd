-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 23, 2024 at 05:41 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `opentrip`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_level_pemandu` ()   BEGIN 
    SELECT nama, pengalaman,
        CASE
            WHEN pengalaman > 5 THEN 'Professional'
            WHEN pengalaman BETWEEN 3 AND 5 THEN 'Senior'
            ELSE 'Junior'
        END AS "Level Pemandu"
    FROM pemandu;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_total_pendapatan` (IN `p_tanggal_mulai` DATE, IN `p_tanggal_selesai` DATE, OUT `p_total_pendapatan` DECIMAL(10,2))   BEGIN
    SELECT SUM(jumlah)
    INTO p_total_pendapatan
    FROM pembayaran
    INNER JOIN pemesanan ON pembayaran.pemesanan_id = pemesanan.pemesanan_id
    WHERE pemesanan.status = 'Confirmed'
      AND tanggal_pemesanan BETWEEN p_tanggal_mulai AND p_tanggal_selesai;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `get_jumlah_pemesanan` (`p_tanggal_mulai` DATE, `p_tanggal_selesai` DATE) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE jumlah_pemesanan INT DEFAULT 0;

    SELECT COUNT(*)
    INTO jumlah_pemesanan
    FROM pemesanan
    WHERE tanggal_pemesanan BETWEEN p_tanggal_mulai AND p_tanggal_selesai;

    RETURN jumlah_pemesanan;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_jumlah_user_aktif` () RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE jumlah_user_aktif INT DEFAULT 0;

    SELECT COUNT(DISTINCT customer_id)
    INTO jumlah_user_aktif
    FROM pemesanan;

    RETURN jumlah_user_aktif;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `nama_lengkap` varchar(100) DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `alamat` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customer_id`, `username`, `password`, `email`, `nama_lengkap`, `no_hp`, `alamat`) VALUES
(1, 'john_doe', 'password123', 'john@example.com', 'John Doe', '081234567890', 'Jl. Kebon Jeruk No. 12, Jakarta'),
(2, 'jane_smith', 'password456', 'jane@example.com', 'Jane Smith', '081234567891', 'Jl. Merdeka No. 34, Bandung'),
(3, 'alice_wong', 'password789', 'alice@example.com', 'Alice Wong', '081234567892', 'Jl. Diponegoro No. 56, Surabaya'),
(4, 'budi_santoso', 'password101', 'budi@example.com', 'Budi Santoso', '081234567896', 'Jl. Sudirman No. 78, Medan'),
(5, 'cindy_tan', 'password202', 'cindy@example.com', 'Cindy Tan', '081234567897', 'Jl. Hasanuddin No. 89, Makassar');

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `before_customer_insert` BEFORE INSERT ON `customer` FOR EACH ROW BEGIN
    DECLARE email_count INT;
    SELECT COUNT(*) INTO email_count FROM customer WHERE email = NEW.email;
    IF email_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pemandu`
--

CREATE TABLE `pemandu` (
  `pemandu_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `pengalaman` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pemandu`
--

INSERT INTO `pemandu` (`pemandu_id`, `nama`, `no_hp`, `email`, `pengalaman`) VALUES
(1, 'Made Wijaya', '081234567893', 'made@example.com', 5),
(2, 'Siti Nurhaliza', '081234567894', 'siti@example.com', 3),
(4, 'Rini Kurniawati', '081234567898', 'rini@example.com', 4),
(5, 'Dedi Kusuma', '081234567899', 'dedi@example.com', 6);

--
-- Triggers `pemandu`
--
DELIMITER $$
CREATE TRIGGER `after_pemandu_delete` AFTER DELETE ON `pemandu` FOR EACH ROW BEGIN
    INSERT INTO pemandu_log (pemandu_id, nama, no_hp, email, pengalaman, action, action_timestamp)
    VALUES (OLD.pemandu_id, OLD.nama, OLD.no_hp, OLD.email, OLD.pengalaman, 'DELETE', NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pemandutrips`
--

CREATE TABLE `pemandutrips` (
  `pemnadu_trip_id` int(11) NOT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `pemandu_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pemandutrips`
--

INSERT INTO `pemandutrips` (`pemnadu_trip_id`, `trip_id`, `pemandu_id`) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5);

-- --------------------------------------------------------

--
-- Table structure for table `pemandu_log`
--

CREATE TABLE `pemandu_log` (
  `log_id` int(11) NOT NULL,
  `pemandu_id` int(11) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `pengalaman` int(11) DEFAULT NULL,
  `action` varchar(10) DEFAULT NULL,
  `action_timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pemandu_log`
--

INSERT INTO `pemandu_log` (`log_id`, `pemandu_id`, `nama`, `no_hp`, `email`, `pengalaman`, `action`, `action_timestamp`) VALUES
(1, 3, 'Agus Santoso', '081234567895', 'agus@example.com', 7, 'DELETE', '2024-07-23 10:38:32');

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran`
--

CREATE TABLE `pembayaran` (
  `pembayaran_id` int(11) NOT NULL,
  `pemesanan_id` int(11) DEFAULT NULL,
  `tanggal_pembayaran` date DEFAULT NULL,
  `jumlah` decimal(10,2) DEFAULT NULL,
  `metode_pembayaran` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pembayaran`
--

INSERT INTO `pembayaran` (`pembayaran_id`, `pemesanan_id`, `tanggal_pembayaran`, `jumlah`, `metode_pembayaran`) VALUES
(1, 1, '2024-07-02', 5000000.00, 'Credit Card'),
(2, 2, '2024-08-21', 3500000.00, 'Bank Transfer'),
(3, 3, '2024-09-10', 4500000.00, 'Credit Card'),
(4, 4, '2024-10-02', 8000000.00, 'PayPal'),
(5, 5, '2024-11-21', 3000000.00, 'Credit Card');

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran_log`
--

CREATE TABLE `pembayaran_log` (
  `pembayaran_id` int(11) NOT NULL,
  `pemesanan_id` int(11) DEFAULT NULL,
  `tanggal_pembayaran` date DEFAULT NULL,
  `jumlah` decimal(10,2) DEFAULT NULL,
  `metode_pembayaran` varchar(50) DEFAULT NULL,
  `tanggal_hapus` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pemesanan`
--

CREATE TABLE `pemesanan` (
  `pemesanan_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `tanggal_pemesanan` date DEFAULT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pemesanan`
--

INSERT INTO `pemesanan` (`pemesanan_id`, `customer_id`, `trip_id`, `tanggal_pemesanan`, `total_harga`, `status`) VALUES
(1, 1, 1, '2024-07-01', 5000000.00, 'Confirmed'),
(2, 2, 2, '2024-08-20', 3500000.00, 'Confirmed'),
(3, 3, 3, '2024-09-05', 4500000.00, 'Pending'),
(4, 4, 4, '2024-10-01', 8000000.00, 'Confirmed'),
(5, 5, 5, '2024-11-20', 3000000.00, 'Pending'),
(6, 6, 6, '2024-07-01', 5000000.00, 'Confirmed');

--
-- Triggers `pemesanan`
--
DELIMITER $$
CREATE TRIGGER `after_pemesanan_insert` AFTER INSERT ON `pemesanan` FOR EACH ROW BEGIN
    INSERT INTO pemesanan_log (pemesanan_id, customer_id, trip_id, tanggal_pemesanan, total_harga, status, action, action_timestamp)
    VALUES (NEW.pemesanan_id, NEW.customer_id, NEW.trip_id, NEW.tanggal_pemesanan, NEW.total_harga, NEW.status, 'INSERT', NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pemesanan_log`
--

CREATE TABLE `pemesanan_log` (
  `log_id` int(11) NOT NULL,
  `pemesanan_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `tanggal_pemesanan` date DEFAULT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `action` varchar(10) DEFAULT NULL,
  `action_timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pemesanan_log`
--

INSERT INTO `pemesanan_log` (`log_id`, `pemesanan_id`, `customer_id`, `trip_id`, `tanggal_pemesanan`, `total_harga`, `status`, `action`, `action_timestamp`) VALUES
(1, 6, 6, 6, '2024-07-01', 5000000.00, 'Confirmed', 'INSERT', '2024-07-23 10:36:34');

-- --------------------------------------------------------

--
-- Stand-in structure for view `pemesanan_user`
-- (See below for the actual view)
--
CREATE TABLE `pemesanan_user` (
`customer_id` int(11)
,`nama_lengkap` varchar(100)
,`total_pemesanan` bigint(21)
,`total_pengeluaran` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `komentar` text DEFAULT NULL,
  `tanggal_review` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`review_id`, `trip_id`, `customer_id`, `rating`, `komentar`, `tanggal_review`) VALUES
(1, 1, 1, 5, 'Liburan yang sangat menyenangkan! Pantai di Bali sangat indah.', '2024-08-10'),
(2, 2, 2, 4, 'Wisata sejarah yang sangat informatif. Makanan lokalnya juga enak.', '2024-09-22'),
(3, 3, 3, 5, 'Petualangan yang luar biasa di Lombok. Mendaki Gunung Rinjani adalah pengalaman tak terlupakan.', '2024-10-20'),
(4, 4, 4, 5, 'Raja Ampat sungguh luar biasa! Pengalaman snorkeling terbaik.', '2024-11-10'),
(5, 5, 5, 5, 'Pemandangan Bromo sangat bagus, apalagi sunrisenya', '2024-12-15');

--
-- Triggers `reviews`
--
DELIMITER $$
CREATE TRIGGER `after_reviews_update` AFTER UPDATE ON `reviews` FOR EACH ROW BEGIN
    INSERT INTO reviews_log (review_id, trip_id, customer_id, rating, komentar, tanggal_review, action, action_timestamp)
    VALUES (NEW.review_id, NEW.trip_id, NEW.customer_id, NEW.rating, NEW.komentar, NEW.tanggal_review, 'UPDATE', NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `reviews_log`
--

CREATE TABLE `reviews_log` (
  `log_id` int(11) NOT NULL,
  `review_id` int(11) DEFAULT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `komentar` text DEFAULT NULL,
  `tanggal_review` date DEFAULT NULL,
  `action` varchar(10) DEFAULT NULL,
  `action_timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews_log`
--

INSERT INTO `reviews_log` (`log_id`, `review_id`, `trip_id`, `customer_id`, `rating`, `komentar`, `tanggal_review`, `action`, `action_timestamp`) VALUES
(1, 5, 5, 5, 5, 'Pemandangan Bromo sangat bagus, apalagi sunrisenya', '2024-12-15', 'UPDATE', '2024-07-23 10:37:47');

-- --------------------------------------------------------

--
-- Table structure for table `trips`
--

CREATE TABLE `trips` (
  `trip_id` int(11) NOT NULL,
  `nama_trip` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `tanggal_mulai` date DEFAULT NULL,
  `tanggal_selesai` date DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `tujuan_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trips`
--

INSERT INTO `trips` (`trip_id`, `nama_trip`, `deskripsi`, `tanggal_mulai`, `tanggal_selesai`, `harga`, `tujuan_id`) VALUES
(1, 'Liburan di Bali', 'Nikmati pantai-pantai indah dan budaya lokal di Bali.', '2024-08-01', '2024-08-07', 5000000.00, 1),
(2, 'Wisata Sejarah di Yogyakarta', 'Kunjungi situs-situs bersejarah dan nikmati kuliner lokal.', '2024-09-15', '2024-09-20', 3500000.00, 2),
(3, 'Petualangan di Lombok', 'Jelajahi keindahan alam Lombok dan mendaki Gunung Rinjani.', '2024-10-10', '2024-10-17', 4500000.00, 3),
(4, 'Eksplorasi Raja Ampat', 'Snorkeling dan diving di perairan jernih Raja Ampat.', '2024-11-01', '2024-11-07', 8000000.00, 4),
(5, 'Pendakian Gunung Bromo', 'Nikmati pemandangan matahari terbit dari puncak Bromo.', '2024-12-10', '2024-12-12', 3000000.00, 5);

--
-- Triggers `trips`
--
DELIMITER $$
CREATE TRIGGER `before_trips_delete` BEFORE DELETE ON `trips` FOR EACH ROW BEGIN
    DECLARE booking_count INT;
    SELECT COUNT(*) INTO booking_count FROM pemesanan WHERE trip_id = OLD.trip_id;
    IF booking_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete trip with existing bookings';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tujuan`
--

CREATE TABLE `tujuan` (
  `tujuan_id` int(11) NOT NULL,
  `tujuan` varchar(100) NOT NULL,
  `lokasi` varchar(100) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tujuan`
--

INSERT INTO `tujuan` (`tujuan_id`, `tujuan`, `lokasi`, `deskripsi`) VALUES
(1, 'Bali', 'Indonesia', 'Pulau tropis terkenal dengan pantai-pantainya yang indah dan budayanya yang kaya.'),
(2, 'Yogyakarta', 'Indonesia', 'Kota dengan banyak situs bersejarah, termasuk Candi Borobudur dan Prambanan.'),
(3, 'Lombok', 'Indonesia', 'Pulau yang indah dengan pantai yang tenang dan Gunung Rinjani.'),
(4, 'Raja Ampat', 'Indonesia', 'Kepulauan dengan keanekaragaman hayati laut yang luar biasa.'),
(5, 'Bromo', 'Indonesia', 'Gunung berapi aktif dengan pemandangan matahari terbit yang spektakuler.');

--
-- Triggers `tujuan`
--
DELIMITER $$
CREATE TRIGGER `before_tujuan_update` BEFORE UPDATE ON `tujuan` FOR EACH ROW BEGIN
    IF NEW.deskripsi IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deskripsi cannot be NULL';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vh_detail_pemesanan`
-- (See below for the actual view)
--
CREATE TABLE `vh_detail_pemesanan` (
`username` varchar(50)
,`nama_trip` varchar(100)
,`harga` decimal(10,2)
,`tujuan` varchar(100)
,`tanggal_pembayaran` date
,`Status_Pembayaran` varchar(50)
,`Nama Pemandu` varchar(100)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_pembayaran_selesai`
-- (See below for the actual view)
--
CREATE TABLE `v_pembayaran_selesai` (
`username` varchar(50)
,`harga` decimal(10,2)
,`tanggal_pembayaran` date
,`Status_Pembayaran` varchar(50)
);

-- --------------------------------------------------------

--
-- Structure for view `pemesanan_user`
--
DROP TABLE IF EXISTS `pemesanan_user`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `pemesanan_user`  AS SELECT `customer`.`customer_id` AS `customer_id`, `customer`.`nama_lengkap` AS `nama_lengkap`, count(`pemesanan`.`pemesanan_id`) AS `total_pemesanan`, sum(`pembayaran`.`jumlah`) AS `total_pengeluaran` FROM ((`customer` left join `pemesanan` on(`customer`.`customer_id` = `pemesanan`.`customer_id`)) left join `pembayaran` on(`pemesanan`.`pemesanan_id` = `pembayaran`.`pemesanan_id`)) GROUP BY `customer`.`customer_id`, `customer`.`nama_lengkap` ;

-- --------------------------------------------------------

--
-- Structure for view `vh_detail_pemesanan`
--
DROP TABLE IF EXISTS `vh_detail_pemesanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vh_detail_pemesanan`  AS SELECT `customer`.`username` AS `username`, `trips`.`nama_trip` AS `nama_trip`, `trips`.`harga` AS `harga`, `tujuan`.`tujuan` AS `tujuan`, `pembayaran`.`tanggal_pembayaran` AS `tanggal_pembayaran`, `pemesanan`.`status` AS `Status_Pembayaran`, `pemandu`.`nama` AS `Nama Pemandu` FROM ((((((`pemesanan` join `customer` on(`pemesanan`.`customer_id` = `customer`.`customer_id`)) join `trips` on(`pemesanan`.`trip_id` = `trips`.`trip_id`)) join `tujuan` on(`trips`.`tujuan_id` = `tujuan`.`tujuan_id`)) join `pemandutrips` on(`trips`.`trip_id` = `pemandutrips`.`trip_id`)) join `pemandu` on(`pemandutrips`.`pemandu_id` = `pemandu`.`pemandu_id`)) join `pembayaran` on(`pembayaran`.`pemesanan_id` = `pemesanan`.`pemesanan_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_pembayaran_selesai`
--
DROP TABLE IF EXISTS `v_pembayaran_selesai`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_pembayaran_selesai`  AS SELECT `dp`.`username` AS `username`, `dp`.`harga` AS `harga`, `dp`.`tanggal_pembayaran` AS `tanggal_pembayaran`, `dp`.`Status_Pembayaran` AS `Status_Pembayaran` FROM `vh_detail_pemesanan` AS `dp` WHERE `dp`.`Status_Pembayaran` = 'Confirmed' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD KEY `idx_username_email` (`username`,`email`);

--
-- Indexes for table `pemandu`
--
ALTER TABLE `pemandu`
  ADD PRIMARY KEY (`pemandu_id`);

--
-- Indexes for table `pemandutrips`
--
ALTER TABLE `pemandutrips`
  ADD PRIMARY KEY (`pemnadu_trip_id`),
  ADD KEY `trip_id` (`trip_id`),
  ADD KEY `pemandu_id` (`pemandu_id`);

--
-- Indexes for table `pemandu_log`
--
ALTER TABLE `pemandu_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD PRIMARY KEY (`pembayaran_id`),
  ADD KEY `pemesanan_id` (`pemesanan_id`);

--
-- Indexes for table `pembayaran_log`
--
ALTER TABLE `pembayaran_log`
  ADD PRIMARY KEY (`pembayaran_id`),
  ADD KEY `idx_tglBayar_tglHapus` (`tanggal_pembayaran`,`tanggal_hapus`);

--
-- Indexes for table `pemesanan`
--
ALTER TABLE `pemesanan`
  ADD PRIMARY KEY (`pemesanan_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `trip_id` (`trip_id`);

--
-- Indexes for table `pemesanan_log`
--
ALTER TABLE `pemesanan_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `trip_id` (`trip_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `reviews_log`
--
ALTER TABLE `reviews_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`trip_id`),
  ADD KEY `tujuan_id` (`tujuan_id`);

--
-- Indexes for table `tujuan`
--
ALTER TABLE `tujuan`
  ADD PRIMARY KEY (`tujuan_id`),
  ADD KEY `idx_tujuan_lokasi` (`tujuan`,`lokasi`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pemandu`
--
ALTER TABLE `pemandu`
  MODIFY `pemandu_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pemandutrips`
--
ALTER TABLE `pemandutrips`
  MODIFY `pemnadu_trip_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pemandu_log`
--
ALTER TABLE `pemandu_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `pembayaran`
--
ALTER TABLE `pembayaran`
  MODIFY `pembayaran_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pembayaran_log`
--
ALTER TABLE `pembayaran_log`
  MODIFY `pembayaran_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pemesanan`
--
ALTER TABLE `pemesanan`
  MODIFY `pemesanan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `pemesanan_log`
--
ALTER TABLE `pemesanan_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `reviews_log`
--
ALTER TABLE `reviews_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `trips`
--
ALTER TABLE `trips`
  MODIFY `trip_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tujuan`
--
ALTER TABLE `tujuan`
  MODIFY `tujuan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `pemandutrips`
--
ALTER TABLE `pemandutrips`
  ADD CONSTRAINT `pemandutrips_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`trip_id`),
  ADD CONSTRAINT `pemandutrips_ibfk_2` FOREIGN KEY (`pemandu_id`) REFERENCES `pemandu` (`pemandu_id`);

--
-- Constraints for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD CONSTRAINT `pembayaran_ibfk_1` FOREIGN KEY (`pemesanan_id`) REFERENCES `pemesanan` (`pemesanan_id`);

--
-- Constraints for table `pemesanan`
--
ALTER TABLE `pemesanan`
  ADD CONSTRAINT `pemesanan_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `pemesanan_ibfk_2` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`trip_id`);

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`trip_id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `trips`
--
ALTER TABLE `trips`
  ADD CONSTRAINT `trips_ibfk_1` FOREIGN KEY (`tujuan_id`) REFERENCES `tujuan` (`tujuan_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
