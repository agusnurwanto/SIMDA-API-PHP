--
-- Table structure for table `database_simda`
--

CREATE TABLE `database_simda` (
  `id` int(11) NOT NULL,
  `nama` varchar(50)  DEFAULT NULL,
  `tahun` year(4)  DEFAULT NULL,
  `username` varchar(10)  DEFAULT NULL,
  `password` varchar(10)  DEFAULT NULL,
  `active` tinyint(4)  DEFAULT NULL,
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET = latin1;

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