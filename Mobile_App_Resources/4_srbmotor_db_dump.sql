-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: localhost    Database: SrbMotor
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('srb-motor-cache-356a192b7913b04c54574d18c28d46e6395428ab','i:1;',1774187599),('srb-motor-cache-356a192b7913b04c54574d18c28d46e6395428ab:timer','i:1774187599;',1774187599),('srb-motor-cache-motors:id:2:withSpecs','O:16:\"App\\Models\\Motor\":33:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:6:\"motors\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:14:{s:2:\"id\";i:2;s:4:\"name\";s:27:\"Yamaha Aerox 155 Cyber City\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:5:\"Aerox\";s:5:\"price\";s:11:\"31200000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:11:\"Sport Matic\";s:10:\"image_path\";s:31:\"assets/img/yamaha/aerox 155.png\";s:7:\"details\";s:134:\"<h3>Aerox 155 Cyber City</h3><p>Desain sporty yang agresif dengan performa mesin yang tangguh. Cocok untuk Anda yang berjiwa muda.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:11:\"\0*\0original\";a:14:{s:2:\"id\";i:2;s:4:\"name\";s:27:\"Yamaha Aerox 155 Cyber City\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:5:\"Aerox\";s:5:\"price\";s:11:\"31200000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:11:\"Sport Matic\";s:10:\"image_path\";s:31:\"assets/img/yamaha/aerox 155.png\";s:7:\"details\";s:134:\"<h3>Aerox 155 Cyber City</h3><p>Desain sporty yang agresif dengan performa mesin yang tangguh. Cocok untuk Anda yang berjiwa muda.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:4:{s:5:\"price\";s:9:\"decimal:2\";s:8:\"tersedia\";s:7:\"boolean\";s:13:\"min_dp_amount\";s:9:\"decimal:2\";s:6:\"colors\";s:5:\"array\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:11:{i:0;s:4:\"name\";i:1;s:5:\"brand\";i:2;s:5:\"model\";i:3;s:5:\"price\";i:4;s:4:\"year\";i:5;s:4:\"type\";i:6;s:10:\"image_path\";i:7;s:7:\"details\";i:8;s:8:\"tersedia\";i:9;s:13:\"min_dp_amount\";i:10;s:6:\"colors\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}}',1774191120),('srb-motor-cache-motors:popular:5:withSpecs','O:39:\"Illuminate\\Database\\Eloquent\\Collection\":2:{s:8:\"\0*\0items\";a:5:{i:0;O:16:\"App\\Models\\Motor\":33:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:6:\"motors\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:14:{s:2:\"id\";i:1;s:4:\"name\";s:22:\"Yamaha NMAX Turbo 2024\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:4:\"NMAX\";s:5:\"price\";s:11:\"35500000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:5:\"Matic\";s:10:\"image_path\";s:32:\"assets/img/yamaha/NMax Turbo.png\";s:7:\"details\";s:225:\"<h3>Fitur Unggulan NMAX Turbo</h3><ul><li>Mesin Blue Core 155cc</li><li>Y-Connect Navigation</li><li>Electric Power Socket</li></ul><p>Nikmati berkendara dengan kenyamanan maksimal dan teknologi turbo terbaru dari Yamaha.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:11:\"\0*\0original\";a:14:{s:2:\"id\";i:1;s:4:\"name\";s:22:\"Yamaha NMAX Turbo 2024\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:4:\"NMAX\";s:5:\"price\";s:11:\"35500000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:5:\"Matic\";s:10:\"image_path\";s:32:\"assets/img/yamaha/NMax Turbo.png\";s:7:\"details\";s:225:\"<h3>Fitur Unggulan NMAX Turbo</h3><ul><li>Mesin Blue Core 155cc</li><li>Y-Connect Navigation</li><li>Electric Power Socket</li></ul><p>Nikmati berkendara dengan kenyamanan maksimal dan teknologi turbo terbaru dari Yamaha.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:4:{s:5:\"price\";s:9:\"decimal:2\";s:8:\"tersedia\";s:7:\"boolean\";s:13:\"min_dp_amount\";s:9:\"decimal:2\";s:6:\"colors\";s:5:\"array\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:11:{i:0;s:4:\"name\";i:1;s:5:\"brand\";i:2;s:5:\"model\";i:3;s:5:\"price\";i:4;s:4:\"year\";i:5;s:4:\"type\";i:6;s:10:\"image_path\";i:7;s:7:\"details\";i:8;s:8:\"tersedia\";i:9;s:13:\"min_dp_amount\";i:10;s:6:\"colors\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}}i:1;O:16:\"App\\Models\\Motor\":33:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:6:\"motors\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:14:{s:2:\"id\";i:2;s:4:\"name\";s:27:\"Yamaha Aerox 155 Cyber City\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:5:\"Aerox\";s:5:\"price\";s:11:\"31200000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:11:\"Sport Matic\";s:10:\"image_path\";s:31:\"assets/img/yamaha/aerox 155.png\";s:7:\"details\";s:134:\"<h3>Aerox 155 Cyber City</h3><p>Desain sporty yang agresif dengan performa mesin yang tangguh. Cocok untuk Anda yang berjiwa muda.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:11:\"\0*\0original\";a:14:{s:2:\"id\";i:2;s:4:\"name\";s:27:\"Yamaha Aerox 155 Cyber City\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:5:\"Aerox\";s:5:\"price\";s:11:\"31200000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:11:\"Sport Matic\";s:10:\"image_path\";s:31:\"assets/img/yamaha/aerox 155.png\";s:7:\"details\";s:134:\"<h3>Aerox 155 Cyber City</h3><p>Desain sporty yang agresif dengan performa mesin yang tangguh. Cocok untuk Anda yang berjiwa muda.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:4:{s:5:\"price\";s:9:\"decimal:2\";s:8:\"tersedia\";s:7:\"boolean\";s:13:\"min_dp_amount\";s:9:\"decimal:2\";s:6:\"colors\";s:5:\"array\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:11:{i:0;s:4:\"name\";i:1;s:5:\"brand\";i:2;s:5:\"model\";i:3;s:5:\"price\";i:4;s:4:\"year\";i:5;s:4:\"type\";i:6;s:10:\"image_path\";i:7;s:7:\"details\";i:8;s:8:\"tersedia\";i:9;s:13:\"min_dp_amount\";i:10;s:6:\"colors\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}}i:2;O:16:\"App\\Models\\Motor\":33:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:6:\"motors\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:14:{s:2:\"id\";i:3;s:4:\"name\";s:25:\"Yamaha Fazzio Lux Edition\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:6:\"Fazzio\";s:5:\"price\";s:11:\"23500000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:6:\"Classy\";s:10:\"image_path\";s:28:\"assets/img/yamaha/Fazzio.png\";s:7:\"details\";s:135:\"<h3>Gaya Hidup Classy dengan Fazzio</h3><p>Motor hybrid pertama di kelasnya. Hemat bahan bakar dan tampil elegan di jalanan Bekasi.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:11:\"\0*\0original\";a:14:{s:2:\"id\";i:3;s:4:\"name\";s:25:\"Yamaha Fazzio Lux Edition\";s:5:\"brand\";s:6:\"Yamaha\";s:5:\"model\";s:6:\"Fazzio\";s:5:\"price\";s:11:\"23500000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:6:\"Classy\";s:10:\"image_path\";s:28:\"assets/img/yamaha/Fazzio.png\";s:7:\"details\";s:135:\"<h3>Gaya Hidup Classy dengan Fazzio</h3><p>Motor hybrid pertama di kelasnya. Hemat bahan bakar dan tampil elegan di jalanan Bekasi.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:4:{s:5:\"price\";s:9:\"decimal:2\";s:8:\"tersedia\";s:7:\"boolean\";s:13:\"min_dp_amount\";s:9:\"decimal:2\";s:6:\"colors\";s:5:\"array\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:11:{i:0;s:4:\"name\";i:1;s:5:\"brand\";i:2;s:5:\"model\";i:3;s:5:\"price\";i:4;s:4:\"year\";i:5;s:4:\"type\";i:6;s:10:\"image_path\";i:7;s:7:\"details\";i:8;s:8:\"tersedia\";i:9;s:13:\"min_dp_amount\";i:10;s:6:\"colors\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}}i:3;O:16:\"App\\Models\\Motor\":33:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:6:\"motors\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:14:{s:2:\"id\";i:4;s:4:\"name\";s:17:\"Honda PCX 160 ABS\";s:5:\"brand\";s:5:\"Honda\";s:5:\"model\";s:7:\"PCX 160\";s:5:\"price\";s:11:\"36000000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:13:\"Matic Premium\";s:10:\"image_path\";s:28:\"assets/img/honda/pcx 160.png\";s:7:\"details\";s:114:\"<h3>Elegansi dan Performa PCX 160</h3><p>Desain mewah dengan performa mesin eSP+ 160cc 4-katup yang bertenaga.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:11:\"\0*\0original\";a:14:{s:2:\"id\";i:4;s:4:\"name\";s:17:\"Honda PCX 160 ABS\";s:5:\"brand\";s:5:\"Honda\";s:5:\"model\";s:7:\"PCX 160\";s:5:\"price\";s:11:\"36000000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:13:\"Matic Premium\";s:10:\"image_path\";s:28:\"assets/img/honda/pcx 160.png\";s:7:\"details\";s:114:\"<h3>Elegansi dan Performa PCX 160</h3><p>Desain mewah dengan performa mesin eSP+ 160cc 4-katup yang bertenaga.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:4:{s:5:\"price\";s:9:\"decimal:2\";s:8:\"tersedia\";s:7:\"boolean\";s:13:\"min_dp_amount\";s:9:\"decimal:2\";s:6:\"colors\";s:5:\"array\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:11:{i:0;s:4:\"name\";i:1;s:5:\"brand\";i:2;s:5:\"model\";i:3;s:5:\"price\";i:4;s:4:\"year\";i:5;s:4:\"type\";i:6;s:10:\"image_path\";i:7;s:7:\"details\";i:8;s:8:\"tersedia\";i:9;s:13:\"min_dp_amount\";i:10;s:6:\"colors\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}}i:4;O:16:\"App\\Models\\Motor\":33:{s:13:\"\0*\0connection\";s:5:\"mysql\";s:8:\"\0*\0table\";s:6:\"motors\";s:13:\"\0*\0primaryKey\";s:2:\"id\";s:10:\"\0*\0keyType\";s:3:\"int\";s:12:\"incrementing\";b:1;s:7:\"\0*\0with\";a:0:{}s:12:\"\0*\0withCount\";a:0:{}s:19:\"preventsLazyLoading\";b:0;s:10:\"\0*\0perPage\";i:15;s:6:\"exists\";b:1;s:18:\"wasRecentlyCreated\";b:0;s:28:\"\0*\0escapeWhenCastingToString\";b:0;s:13:\"\0*\0attributes\";a:14:{s:2:\"id\";i:5;s:4:\"name\";s:15:\"Honda Vario 160\";s:5:\"brand\";s:5:\"Honda\";s:5:\"model\";s:9:\"Vario 160\";s:5:\"price\";s:11:\"27350000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:11:\"Sport Matic\";s:10:\"image_path\";s:30:\"assets/img/honda/vario 160.png\";s:7:\"details\";s:133:\"<h3>Vario 160 Bigger, Greater</h3><p>Tampil lebih besar dan tangguh dengan mesin 160cc untuk aktivitas sehari-hari gaya maksimal.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:11:\"\0*\0original\";a:14:{s:2:\"id\";i:5;s:4:\"name\";s:15:\"Honda Vario 160\";s:5:\"brand\";s:5:\"Honda\";s:5:\"model\";s:9:\"Vario 160\";s:5:\"price\";s:11:\"27350000.00\";s:13:\"min_dp_amount\";s:1:\"0\";s:6:\"colors\";N;s:4:\"year\";i:2024;s:4:\"type\";s:11:\"Sport Matic\";s:10:\"image_path\";s:30:\"assets/img/honda/vario 160.png\";s:7:\"details\";s:133:\"<h3>Vario 160 Bigger, Greater</h3><p>Tampil lebih besar dan tangguh dengan mesin 160cc untuk aktivitas sehari-hari gaya maksimal.</p>\";s:8:\"tersedia\";i:1;s:10:\"created_at\";s:19:\"2026-03-22 20:43:56\";s:10:\"updated_at\";s:19:\"2026-03-22 20:43:56\";}s:10:\"\0*\0changes\";a:0:{}s:11:\"\0*\0previous\";a:0:{}s:8:\"\0*\0casts\";a:4:{s:5:\"price\";s:9:\"decimal:2\";s:8:\"tersedia\";s:7:\"boolean\";s:13:\"min_dp_amount\";s:9:\"decimal:2\";s:6:\"colors\";s:5:\"array\";}s:17:\"\0*\0classCastCache\";a:0:{}s:21:\"\0*\0attributeCastCache\";a:0:{}s:13:\"\0*\0dateFormat\";N;s:10:\"\0*\0appends\";a:0:{}s:19:\"\0*\0dispatchesEvents\";a:0:{}s:14:\"\0*\0observables\";a:0:{}s:12:\"\0*\0relations\";a:0:{}s:10:\"\0*\0touches\";a:0:{}s:27:\"\0*\0relationAutoloadCallback\";N;s:26:\"\0*\0relationAutoloadContext\";N;s:10:\"timestamps\";b:1;s:13:\"usesUniqueIds\";b:0;s:9:\"\0*\0hidden\";a:0:{}s:10:\"\0*\0visible\";a:0:{}s:11:\"\0*\0fillable\";a:11:{i:0;s:4:\"name\";i:1;s:5:\"brand\";i:2;s:5:\"model\";i:3;s:5:\"price\";i:4;s:4:\"year\";i:5;s:4:\"type\";i:6;s:10:\"image_path\";i:7;s:7:\"details\";i:8;s:8:\"tersedia\";i:9;s:13:\"min_dp_amount\";i:10;s:6:\"colors\";}s:10:\"\0*\0guarded\";a:1:{i:0;s:1:\"*\";}}}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}',1774191115);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_name_unique` (`name`),
  UNIQUE KEY `categories_slug_unique` (`slug`),
  KEY `categories_is_active_index` (`is_active`),
  KEY `categories_order_index` (`order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credit_details`
--

DROP TABLE IF EXISTS `credit_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credit_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint unsigned NOT NULL,
  `leasing_provider_id` bigint unsigned DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pengajuan_masuk',
  `reference_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Leasing provider reference',
  `tenor` int NOT NULL COMMENT 'Loan tenure in months',
  `interest_rate` decimal(5,2) DEFAULT NULL COMMENT 'Annual interest rate %',
  `monthly_installment` decimal(15,0) DEFAULT NULL,
  `verification_notes` text COLLATE utf8mb4_unicode_ci,
  `verified_at` timestamp NULL DEFAULT NULL,
  `dp_amount` decimal(15,0) DEFAULT NULL COMMENT 'Down payment amount required',
  `dp_paid_at` timestamp NULL DEFAULT NULL,
  `dp_payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `completion_notes` text COLLATE utf8mb4_unicode_ci,
  `is_completed` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `credit_details_reference_number_unique` (`reference_number`),
  KEY `credit_details_transaction_id_index` (`transaction_id`),
  KEY `credit_details_status_index` (`status`),
  KEY `credit_details_leasing_provider_id_index` (`leasing_provider_id`),
  CONSTRAINT `credit_details_leasing_provider_id_foreign` FOREIGN KEY (`leasing_provider_id`) REFERENCES `leasing_providers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `credit_details_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credit_details`
--

LOCK TABLES `credit_details` WRITE;
/*!40000 ALTER TABLE `credit_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `credit_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `credit_detail_id` bigint unsigned NOT NULL,
  `document_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'KTP, BPKB, STNK, Slip Gaji, Bukti Domisili, etc',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Path to stored file',
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'pending, approved, rejected',
  `approval_status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'pending, approved, rejected',
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `documents_credit_detail_id_index` (`credit_detail_id`),
  KEY `documents_status_index` (`status`),
  KEY `documents_approval_status_index` (`approval_status`),
  CONSTRAINT `documents_credit_detail_id_foreign` FOREIGN KEY (`credit_detail_id`) REFERENCES `credit_details` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `installments`
--

DROP TABLE IF EXISTS `installments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `installments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint unsigned NOT NULL,
  `installment_number` int NOT NULL COMMENT '1st, 2nd, 3rd... installment',
  `due_date` date NOT NULL COMMENT 'When payment is due',
  `amount` decimal(15,0) NOT NULL COMMENT 'Monthly installment amount',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'belum_dibayar' COMMENT 'belum_dibayar, dibayar, overdue, tertangguh',
  `paid_at` timestamp NULL DEFAULT NULL,
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank transfer, online, cash, etc',
  `payment_proof` text COLLATE utf8mb4_unicode_ci COMMENT 'Path to payment proof file',
  `snap_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Midtrans Snap payment token',
  `midtrans_booking_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_overdue` tinyint(1) NOT NULL DEFAULT '0',
  `days_overdue` int NOT NULL DEFAULT '0',
  `penalty_amount` decimal(15,0) NOT NULL DEFAULT '0' COMMENT 'Late payment penalty',
  `total_with_penalty` decimal(15,0) DEFAULT NULL,
  `reminder_sent` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Whether reminder notification sent',
  `reminder_sent_at` timestamp NULL DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `installments_transaction_id_index` (`transaction_id`),
  KEY `installments_status_index` (`status`),
  KEY `installments_due_date_index` (`due_date`),
  CONSTRAINT `installments_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `installments`
--

LOCK TABLES `installments` WRITE;
/*!40000 ALTER TABLE `installments` DISABLE KEYS */;
/*!40000 ALTER TABLE `installments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leasing_providers`
--

DROP TABLE IF EXISTS `leasing_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leasing_providers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `logo_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leasing_providers`
--

LOCK TABLES `leasing_providers` WRITE;
/*!40000 ALTER TABLE `leasing_providers` DISABLE KEYS */;
INSERT INTO `leasing_providers` VALUES (1,'BAF (Bussan Auto Finance)',NULL,'2026-03-22 13:43:56','2026-03-22 13:43:56'),(2,'Adira Finance',NULL,'2026-03-22 13:43:56','2026-03-22 13:43:56');
/*!40000 ALTER TABLE `leasing_providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000001_create_cache_table',1),(2,'0001_01_01_000002_create_jobs_table',1),(3,'2025_10_30_092515_create_complete_motors_table',1),(4,'2025_10_30_092517_create_complete_contact_messages_table',1),(5,'2025_11_04_000000_consolidate_users_table',1),(6,'2025_11_05_064733_create_complete_notifications_table',1),(7,'2025_11_05_140000_create_sessions_table',1),(8,'2025_11_05_150000_create_password_reset_tokens_table',1),(9,'2025_11_05_160000_create_personal_access_tokens_table',1),(10,'2025_11_07_120000_add_indexes_to_tables',1),(11,'2025_11_19_125905_make_subject_nullable_in_contact_messages_table',1),(12,'2026_03_07_195731_create_promotions_tables',1),(13,'2026_03_07_195734_create_leasing_tables',1),(14,'2026_03_10_000001_create_settings_table',1),(15,'2026_03_10_000002_create_banners_table',1),(16,'2026_03_10_000003_create_categories_table',1),(17,'2026_03_10_000004_create_posts_table',1),(18,'2026_03_11_000200_consolidate_transactions_table',1),(19,'2026_03_11_000300_consolidate_credit_details_table',1),(20,'2026_03_11_000400_consolidate_installments_table',1),(21,'2026_03_11_000500_consolidate_survey_schedules_table',1),(22,'2026_03_11_000600_consolidate_documents_table',1),(23,'2026_03_11_161725_add_customer_fields_to_transactions_table',1),(24,'2026_03_11_162000_add_missing_survey_fields_to_survey_schedules_table',1),(25,'2026_03_12_204027_add_modern_cash_fields_to_transactions_table',1),(26,'2026_03_13_051133_add_midtrans_fields_to_installments_table',1),(27,'2026_03_13_052626_rename_paid_date_to_paid_at_in_installments_table',1),(28,'2026_03_13_155522_add_min_dp_to_motors_and_drop_schemes',1),(29,'2026_03_13_161537_create_user_profiles_table',1),(30,'2026_03_13_161719_create_transaction_logs_table',1),(31,'2026_03_13_161958_cleanup_users_table',1),(32,'2026_03_13_162704_create_motor_units_table',1),(33,'2026_03_13_162809_add_motor_unit_id_to_transactions_table',1),(34,'2026_03_14_225011_simplify_inventory_to_colors',1),(35,'2026_03_15_133554_drop_banner_promo_contact_tables',1),(36,'2026_03_16_021537_cleanup_orphaned_motor_units',1),(37,'2026_03_16_021608_merge_user_profiles_to_users',1),(38,'2026_03_17_161341_remove_redundant_columns_from_transactions_table',1),(39,'2026_03_17_162010_consolidate_redundant_database_columns',1),(40,'2026_03_18_000000_update_transaction_logs_table',1),(41,'2026_03_22_201331_add_email_to_transactions_table',2),(42,'2026_03_22_203729_remove_unused_columns',2);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `motors`
--

DROP TABLE IF EXISTS `motors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `motors` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `brand` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `min_dp_amount` decimal(15,0) NOT NULL DEFAULT '0' COMMENT 'Minimum Down Payment for this motor',
  `colors` json DEFAULT NULL,
  `year` int DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci,
  `tersedia` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `motors_brand_type_index` (`brand`,`type`),
  KEY `motors_year_index` (`year`),
  KEY `motors_price_index` (`price`),
  KEY `motors_tersedia_index` (`tersedia`),
  KEY `motors_brand_tersedia_index` (`brand`,`tersedia`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `motors`
--

LOCK TABLES `motors` WRITE;
/*!40000 ALTER TABLE `motors` DISABLE KEYS */;
INSERT INTO `motors` VALUES (1,'Yamaha NMAX Turbo 2024','Yamaha','NMAX',35500000.00,0,NULL,2024,'Matic','assets/img/yamaha/NMax Turbo.png','<h3>Fitur Unggulan NMAX Turbo</h3><ul><li>Mesin Blue Core 155cc</li><li>Y-Connect Navigation</li><li>Electric Power Socket</li></ul><p>Nikmati berkendara dengan kenyamanan maksimal dan teknologi turbo terbaru dari Yamaha.</p>',1,'2026-03-22 13:43:56','2026-03-22 13:43:56'),(2,'Yamaha Aerox 155 Cyber City','Yamaha','Aerox',31200000.00,0,NULL,2024,'Sport Matic','assets/img/yamaha/aerox 155.png','<h3>Aerox 155 Cyber City</h3><p>Desain sporty yang agresif dengan performa mesin yang tangguh. Cocok untuk Anda yang berjiwa muda.</p>',1,'2026-03-22 13:43:56','2026-03-22 13:43:56'),(3,'Yamaha Fazzio Lux Edition','Yamaha','Fazzio',23500000.00,0,NULL,2024,'Classy','assets/img/yamaha/Fazzio.png','<h3>Gaya Hidup Classy dengan Fazzio</h3><p>Motor hybrid pertama di kelasnya. Hemat bahan bakar dan tampil elegan di jalanan Bekasi.</p>',1,'2026-03-22 13:43:56','2026-03-22 13:43:56'),(4,'Honda PCX 160 ABS','Honda','PCX 160',36000000.00,0,NULL,2024,'Matic Premium','assets/img/honda/pcx 160.png','<h3>Elegansi dan Performa PCX 160</h3><p>Desain mewah dengan performa mesin eSP+ 160cc 4-katup yang bertenaga.</p>',1,'2026-03-22 13:43:56','2026-03-22 13:43:56'),(5,'Honda Vario 160','Honda','Vario 160',27350000.00,0,NULL,2024,'Sport Matic','assets/img/honda/vario 160.png','<h3>Vario 160 Bigger, Greater</h3><p>Tampil lebih besar dan tangguh dengan mesin 160cc untuk aktivitas sehari-hari gaya maksimal.</p>',1,'2026-03-22 13:43:56','2026-03-22 13:43:56'),(6,'Honda Scoopy Prestige','Honda','Scoopy',22000000.00,0,NULL,2024,'Classic','assets/img/honda/scoopy.png','<h3>Scoopy Klasik yang Ikonik</h3><p>Fitur Smart Key System lengkap gaya retro yang abadi sepanjang masa.</p>',1,'2026-03-22 13:43:56','2026-03-22 13:43:56');
/*!40000 ALTER TABLE `motors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notifiable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notifiable_id` bigint unsigned NOT NULL,
  `data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `category_id` bigint unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `featured_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `excerpt` text COLLATE utf8mb4_unicode_ci,
  `status` enum('draft','published','archived') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `views` bigint unsigned NOT NULL DEFAULT '0',
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `posts_slug_unique` (`slug`),
  KEY `posts_category_id_foreign` (`category_id`),
  KEY `posts_slug_index` (`slug`),
  KEY `posts_status_index` (`status`),
  KEY `posts_published_at_index` (`published_at`),
  CONSTRAINT `posts_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('hSCmYvrFT2yFdj0eMCxiX9r8DGe1MJbbCvIUNbRK',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoialltVkFkRkhNTVBXNjFKSEd5OFJIMUhkeDFjdUZPYklWNFRwRDlQayI7czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czoyMToiaHR0cDovL2xvY2FsaG9zdDo4MDAwIjtzOjU6InJvdXRlIjtzOjQ6ImhvbWUiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19',1774187539),('kWPL5Uz5EegDJtlcR6KVUxx31z4VYvy5IXiGfSZR',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiUUFQMDJrWkFlQjlpNUhSOFV6Q3duQ2hNNzVnSzBlelA5NWc1R0FBZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzI6Imh0dHA6Ly9zcmJtb3Rvci50ZXN0L2F1dGgvZ29vZ2xlIjtzOjU6InJvdXRlIjtzOjExOiJhdXRoLmdvb2dsZSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1774185994);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` longtext COLLATE utf8mb4_unicode_ci,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string',
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_key_unique` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_schedules`
--

DROP TABLE IF EXISTS `survey_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_schedules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `credit_detail_id` bigint unsigned NOT NULL,
  `scheduled_date` datetime NOT NULL COMMENT 'When survey is scheduled',
  `scheduled_time` time DEFAULT NULL,
  `surveyor_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `surveyor_phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled' COMMENT 'scheduled, completed, rescheduled, cancelled',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `customer_notes` text COLLATE utf8mb4_unicode_ci,
  `customer_confirms` tinyint(1) NOT NULL DEFAULT '0',
  `customer_confirmed_at` timestamp NULL DEFAULT NULL,
  `customer_confirmation_notes` text COLLATE utf8mb4_unicode_ci,
  `completed_at` timestamp NULL DEFAULT NULL,
  `survey_result` text COLLATE utf8mb4_unicode_ci,
  `findings` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `survey_schedules_credit_detail_id_index` (`credit_detail_id`),
  KEY `survey_schedules_status_index` (`status`),
  CONSTRAINT `survey_schedules_credit_detail_id_foreign` FOREIGN KEY (`credit_detail_id`) REFERENCES `credit_details` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_schedules`
--

LOCK TABLES `survey_schedules` WRITE;
/*!40000 ALTER TABLE `survey_schedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_logs`
--

DROP TABLE IF EXISTS `transaction_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint unsigned NOT NULL,
  `status_from` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_to` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `actor_id` bigint unsigned DEFAULT NULL,
  `actor_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `payload` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_logs_transaction_id_foreign` (`transaction_id`),
  CONSTRAINT `transaction_logs_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_logs`
--

LOCK TABLES `transaction_logs` WRITE;
/*!40000 ALTER TABLE `transaction_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nik` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Transaction reference code',
  `transaction_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'CASH, CREDIT, TRADE-IN, etc',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `motor_id` bigint unsigned NOT NULL,
  `motor_color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `motor_price` decimal(15,0) NOT NULL COMMENT 'Motor selling price',
  `booking_fee` decimal(15,0) DEFAULT '0',
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Customer phone number',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci COMMENT 'Customer delivery address',
  `delivery_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `occupation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `monthly_income` decimal(15,0) DEFAULT NULL,
  `employment_duration` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_price` decimal(15,0) NOT NULL,
  `final_price` decimal(15,0) NOT NULL,
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank transfer, cash, installment, etc',
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `cancellation_reason` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transactions_reference_number_unique` (`reference_number`),
  KEY `transactions_motor_id_foreign` (`motor_id`),
  KEY `transactions_user_id_index` (`user_id`),
  KEY `transactions_status_index` (`status`),
  KEY `transactions_transaction_type_index` (`transaction_type`),
  CONSTRAINT `transactions_motor_id_foreign` FOREIGN KEY (`motor_id`) REFERENCES `motors` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `google_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_photo_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `alamat` text COLLATE utf8mb4_unicode_ci,
  `nik` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `occupation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `monthly_income` decimal(15,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_google_id_unique` (`google_id`),
  KEY `users_role_index` (`role`),
  KEY `users_email_index` (`email`),
  KEY `users_created_at_index` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Mamat Gunshop','gunshopmamat025@gmail.com',NULL,'$2y$12$uvHF29s54yjhUNLMJJnJZeu6TzjjZyLZLrqQ3b5y7r2ILoYSTsFbq','cm5EwiNX0t0BC3nDpcZGsxMqVQ2rExSEHSGMhuYqZ5UHGihqDTqS8t1JMkzt','user','100585967897353650015','https://lh3.googleusercontent.com/a/ACg8ocIr_2g3M0P2RHK2OJlsx5Y1_kOTt42MO0ga_jXre0l7YXVqSw=s96-c',NULL,'2026-03-22 13:26:42','2026-03-22 13:26:42',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-23 13:42:45
