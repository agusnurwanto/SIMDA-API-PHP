--
-- Table structure for table `database_simda`
--

CREATE TABLE `database_simda` (
  `id` int(11) NOT NULL,
  `hostname` varchar(50)  DEFAULT NULL COMMENT 'HOST atau DSN ODBC',
  `nama` varchar(50)  DEFAULT NULL COMMENT 'Nama Database',
  `tahun` year(4)  DEFAULT NULL COMMENT 'Tahun anggaran',
  `username` varchar(10)  DEFAULT NULL COMMENT 'User SQL SERVER',
  `password` varchar(10)  DEFAULT NULL COMMENT 'Password SQL SERVER',
  `active` tinyint(4)  DEFAULT 1  COMMENT '1=aktif, 0=nonaktif',
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET = latin1;

--
-- Dumping data for table `database_simda`
--

INSERT INTO `database_simda` (`id`, `hostname`, `nama`, `tahun`, `username`, `password`, `active`, `keterangan`) VALUES
(1, 'localhost', 'simda_2021', 2021, 'sa', NULL, 1, 'Database simda tahun 2021');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `database_simda`
--
ALTER TABLE `database_simda`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `database_simda`
--
ALTER TABLE `database_simda`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;