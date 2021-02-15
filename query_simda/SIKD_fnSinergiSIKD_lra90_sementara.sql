CREATE FUNCTION fn_SinergiSIKD_lra90_sementara(@Tahun smallint, @Bulan tinyint)
RETURNS TABLE
WITH ENCRYPTION
AS
RETURN (
	SELECT @Bulan AS periode,
		CONVERT(varchar, H.Kd_Urusan1) + '.' + RIGHT('0' + CONVERT(varchar, H.Kd_Bidang1), 2) AS kodeUrusanProgram,
		M.Nm_Urusan + ' ' + L.Nm_Bidang AS namaUrusanProgram,
		CONVERT(varchar, A.Kd_Urusan) + '.' + RIGHT('0' + CONVERT(varchar, A.Kd_Bidang), 2) AS kodeUrusanPelaksana,
		K.Nm_Urusan + ' ' + J.Nm_Bidang AS namaUrusanPelaksana,
		LEFT(RIGHT('0' + CONVERT(varchar, A.Kd_Unit), 2) + '00', 4) AS kodeSKPD,
		I.Nm_Unit AS namaSKPD,
		RIGHT('00' + CONVERT(varchar, A.Kd_Prog), 3) AS kodeProgram,
		H.Ket_Program AS namaProgram,
		RIGHT('00' + CONVERT(varchar, A.Kd_Keg), 3) + '000' AS kodeKegiatan,
		G.Ket_Kegiatan AS namaKegiatan,
		RIGHT('0' + CONVERT(varchar, L.Kd_Fungsi), 2) AS kodeFungsi,
		N.Nm_Fungsi AS namaFungsi,
		CONVERT(varchar, R1.Kd_Rek90_1) AS kodeAkunUtama,
		R1.Nm_Rek90_1 AS namaAkunUtama,
		CONVERT(varchar, R2.Kd_Rek90_2) AS kodeAkunKelompok,
		R2.Nm_Rek90_2 AS namaAkunKelompok,
		CONVERT(varchar, R3.Kd_Rek90_3) AS kodeAkunJenis,
		R3.Nm_Rek90_3 AS namaAkunJenis,
		RIGHT('0' + CONVERT(varchar, R4.Kd_Rek90_4), 2) AS kodeAkunObjek,
		R4.Nm_Rek90_4 AS namaAkunObjek,
		RIGHT('0' + CONVERT(varchar, R5.Kd_Rek90_5), 2) AS kodeAkunRincian,
		R5.Nm_Rek90_5 AS namaAkunRincian,
		RIGHT('0' + CONVERT(varchar, R6.Kd_Rek90_6), 2) AS kodeAkunSub,
		R6.Nm_Rek90_6 AS namaAkunSub,
		A.Total AS nilaiRealisasi
	FROM 
		(
			SELECT Tahun, Kd_Urusan, Kd_Bidang, Kd_Unit, Kd_Sub, Kd_Prog, Id_Prog, Kd_Keg, 
				Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, SUM(Total) AS Total
			FROM (
				--- Anggaran
				--SELECT Tahun, Kd_Urusan, Kd_Bidang, Kd_Unit, Kd_Sub, Kd_Prog, Id_Prog, Kd_Keg, 
				--	Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, 0 Realisasi
				--FROM Ta_RASK_Arsip WHERE Kd_Perubahan = (SELECT MAX(Kd_Perubahan) FROM Ta_RASK_Arsip_Perubahan WHERE MONTH(Tgl_Perda) <= @Bulan)
				--AND Kd_Rek_1 IN (4,5,6)

				--UNION ALL
				SELECT  b.Tahun, b.Kd_Urusan, b.Kd_Bidang, b.Kd_Unit, b.Kd_Sub, Kd_Prog, Id_Prog, Kd_Keg, 
					Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Nilai Total
				FROM    Ta_SP2D a
				INNER JOIN Ta_SPM b ON a.No_SPM = b.No_SPM AND a.Tahun = b.Tahun
				INNER JOIN Ta_SPM_Rinc c ON c.No_SPM = b.No_SPM AND c.Tahun = b.Tahun
				WHERE   b.Jn_SPM IN (2,3,5)
				AND     MONTH(a.Tgl_SP2D) <= @Bulan

				UNION ALL

				SELECT  a.Tahun, a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub, Kd_Prog, Id_Prog, Kd_Keg, 
					Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, CASE WHEN D_K = 'D' THEN Nilai ELSE -Nilai END Total
				FROM    Ta_Penyesuaian a
				INNER JOIN Ta_Penyesuaian_Rinc b ON a.Tahun = b.Tahun AND a.No_Bukti = b.No_Bukti
				WHERE a.Jns_P1 = 1 AND a.Jns_P2 = 3
				AND     MONTH(a.Tgl_Bukti) <= @Bulan

				UNION ALL

				SELECT a.Tahun, Kd_Urusan, Kd_Bidang, Kd_Unit, Kd_Sub, 0 Kd_Prog, 0 Id_Prog, 0 Kd_Keg, 
					Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Nilai Total
				FROM   Ta_Bukti_Penerimaan a
				INNER JOIN Ta_Bukti_Penerimaan_Rinc b ON a.Tahun = b.Tahun AND a.No_Bukti = b.No_Bukti
				WHERE  MONTH(a.Tgl_Bukti) <= @Bulan

				UNION ALL

				SELECT a.Tahun, a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub, Kd_Prog, Id_Prog, Kd_Keg,
					Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Nilai Total
				FROM   Ta_STS a
				INNER JOIN Ta_STS_Rinc b ON a.Tahun = b.Tahun AND a.No_STS = b.No_STS
				WHERE  MONTH(a.Tgl_STS) <= @Bulan AND Kd_SKPD = 2

				UNION ALL

				SELECT a.Tahun, b.Kd_Urusan, b.Kd_Bidang, b.Kd_Unit, b.Kd_Sub, Kd_Prog, Id_Prog, Kd_Keg, 
					Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Nilai Total
				FROM   Ta_SP2B a
				INNER JOIN Ta_SP3B b ON a.Tahun = b.Tahun AND a.No_SP3B = b.No_SP3B
				INNER JOIN Ta_SP3B_Rinc c  ON c.Tahun = b.Tahun AND c.No_SP3B = b.No_SP3B
				WHERE  MONTH(a.Tgl_SP2B) <= @Bulan

				UNION ALL

				SELECT Tahun, Kd_Urusan, Kd_Bidang, Kd_Unit, Kd_Sub, 0 Kd_Prog, 0 Id_Prog, 0 Kd_Keg, 
					Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Nilai Total
				FROM Ta_Realisasi_Pembiayaan a
				WHERE MONTH(Tgl_Bukti) <= @Bulan
			) Z 
			GROUP BY Tahun, Kd_Urusan, Kd_Bidang, Kd_Unit, Kd_Sub, Kd_Prog, Id_Prog, Kd_Keg, 
				Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5			
		) A INNER JOIN
		Ref_Rek_Mapping B ON A.Kd_Rek_1 = B.Kd_Rek_1 AND A.Kd_Rek_2 = B.Kd_Rek_2 AND A.Kd_Rek_3 = B.Kd_Rek_3 AND A.Kd_Rek_4 = B.Kd_Rek_4 AND A.Kd_Rek_5 = B.Kd_Rek_5 INNER JOIN
		Ref_Rek90_6 R6 ON R6.Kd_Rek90_1 = B.Kd_Rek90_1 AND R6.Kd_Rek90_2 = B.Kd_Rek90_2 AND R6.Kd_Rek90_3 = B.Kd_Rek90_3 AND R6.Kd_Rek90_4 = B.Kd_Rek90_4 AND R6.Kd_Rek90_5 = B.Kd_Rek90_5 AND R6.Kd_Rek90_6 = B.Kd_Rek90_6 INNER JOIN
		Ref_Rek90_5 R5 ON R5.Kd_Rek90_1 = R6.Kd_Rek90_1 AND R5.Kd_Rek90_2 = R6.Kd_Rek90_2 AND R5.Kd_Rek90_3 = R6.Kd_Rek90_3 AND R5.Kd_Rek90_4 = R6.Kd_Rek90_4 AND R5.Kd_Rek90_5 = R6.Kd_Rek90_5  INNER JOIN
		Ref_Rek90_4 R4 ON R4.Kd_Rek90_1 = R5.Kd_Rek90_1 AND R4.Kd_Rek90_2 = R5.Kd_Rek90_2 AND R4.Kd_Rek90_3 = R5.Kd_Rek90_3 AND R4.Kd_Rek90_4 = R5.Kd_Rek90_4 INNER JOIN
		Ref_Rek90_3 R3 ON R3.Kd_Rek90_1 = R4.Kd_Rek90_1 AND R3.Kd_Rek90_2 = R4.Kd_Rek90_2 AND R3.Kd_Rek90_3 = R4.Kd_Rek90_3 INNER JOIN
		Ref_Rek90_2 R2 ON R2.Kd_Rek90_1 = R3.Kd_Rek90_1 AND R2.Kd_Rek90_2 = R3.Kd_Rek90_2 INNER JOIN
		Ref_Rek90_1 R1 ON R1.Kd_Rek90_1 = R2.Kd_Rek90_1 INNER JOIN
		
		Ta_Kegiatan G ON A.Tahun = G.Tahun AND A.Kd_Urusan = G.Kd_Urusan AND A.Kd_Bidang = G.Kd_Bidang AND A.Kd_Unit = G.Kd_Unit AND A.Kd_Sub = G.Kd_Sub AND A.Kd_Prog = G.Kd_Prog AND A.ID_Prog = G.ID_Prog AND A.Kd_Keg = G.Kd_Keg INNER JOIN
		Ta_Program H ON G.Tahun = H.Tahun AND G.Kd_Urusan = H.Kd_Urusan AND G.Kd_Bidang = H.Kd_Bidang AND G.Kd_Unit = H.Kd_Unit AND G.Kd_Sub = H.Kd_Sub AND G.Kd_Prog = H.Kd_Prog AND G.ID_Prog = H.ID_Prog INNER JOIN
		Ref_Unit I ON A.Kd_Urusan = I.Kd_Urusan AND A.Kd_Bidang = I.Kd_Bidang AND A.Kd_Unit = I.Kd_Unit INNER JOIN
		Ref_Bidang J ON I.Kd_Urusan = J.Kd_Urusan AND I.Kd_Bidang = J.Kd_Bidang INNER JOIN
		Ref_Urusan K ON J.Kd_Urusan = K.Kd_Urusan INNER JOIN
		Ref_Bidang L ON H.Kd_Urusan1 = L.Kd_Urusan AND H.Kd_Bidang1 = L.Kd_Bidang INNER JOIN
		Ref_Urusan M ON L.Kd_Urusan = M.Kd_Urusan INNER JOIN
		Ref_Fungsi N ON L.Kd_Fungsi = N.Kd_Fungsi
)
