DECLARE @tgl DATETIME
SELECT @tgl = '2021/01/31'
IF OBJECT_ID('#temp1') IS NOT NULL 
    DROP TABLE #temp1


SELECT y.Kd_Rek90_1, y.Kd_Rek90_2, y.Kd_Rek90_3, y.Kd_Rek90_4, y.Kd_Rek90_5, y.Kd_Rek90_6, 
    SUM(Anggaran) Anggaran, SUM(Realisasi) Realisasi, 5 Lvl INTO #temp1
FROM (
    SELECT Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Total Anggaran, 0 Realisasi
    FROM Ta_RASK_Arsip WHERE Kd_Perubahan = (SELECT MAX(Kd_Perubahan) FROM Ta_RASK_Arsip_Perubahan WHERE Tgl_Perda <= @tgl)
    AND Kd_Rek_1 IN (4,5,6)
    
    UNION ALL
    
    SELECT  Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, 0 Anggaran, Nilai Realisasi
    FROM    Ta_SP2D a
    INNER JOIN Ta_SPM b ON a.No_SPM = b.No_SPM AND a.Tahun = b.Tahun
    INNER JOIN Ta_SPM_Rinc c ON c.No_SPM = b.No_SPM AND c.Tahun = b.Tahun
    WHERE   b.Jn_SPM IN (2,3,5)
    AND     a.Tgl_SP2D <= @tgl 
    
    UNION ALL
    
    SELECT  Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, 0 Anggaran, CASE WHEN D_K = 'D' THEN Nilai ELSE -Nilai END Realisasi
    FROM    Ta_Penyesuaian a
    INNER JOIN Ta_Penyesuaian_Rinc b ON a.Tahun = b.Tahun AND a.No_Bukti = b.No_Bukti
    WHERE a.Jns_P1 = 1 AND a.Jns_P2 = 3
    AND     a.Tgl_Bukti <= @tgl
    
    UNION ALL
    
    SELECT Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, 0 Anggaran, Nilai Realisasi
    FROM   Ta_Bukti_Penerimaan a
    INNER JOIN Ta_Bukti_Penerimaan_Rinc b ON a.Tahun = b.Tahun AND a.No_Bukti = b.No_Bukti
    WHERE  a.Tgl_Bukti <= @tgl
    
    UNION ALL
    
    SELECT Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, 0 Anggaran, Nilai Realisasi
    FROM   Ta_STS a
    INNER JOIN Ta_STS_Rinc b ON a.Tahun = b.Tahun AND a.No_STS = b.No_STS
    WHERE  a.Tgl_STS <= @tgl AND Kd_SKPD = 2
    
    UNION ALL
    
    SELECT Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, 0 Anggaran, Nilai Realisasi
    FROM   Ta_SP2B a
    INNER JOIN Ta_SP3B b ON a.Tahun = b.Tahun AND a.No_SP3B = b.No_SP3B
    INNER JOIN Ta_SP3B_Rinc c  ON c.Tahun = b.Tahun AND c.No_SP3B = b.No_SP3B
    WHERE  a.Tgl_SP2B <= @tgl
    
    UNION ALL
    
    SELECT Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, 0 Anggaran, Nilai Realisasi
    FROM Ta_Realisasi_Pembiayaan a
    WHERE Tgl_Bukti <= @tgl
    
) x
INNER JOIN Ref_Rek_Mapping y ON x.Kd_Rek_1 = y.Kd_Rek_1 AND x.Kd_Rek_2 = y.Kd_Rek_2 AND x.Kd_Rek_3 = y.Kd_Rek_3 AND 
    x.Kd_Rek_4 = y.Kd_Rek_4 AND x.Kd_Rek_5 = y.Kd_Rek_5
GROUP BY y.Kd_Rek90_1, y.Kd_Rek90_2, y.Kd_Rek90_3, y.Kd_Rek90_4, y.Kd_Rek90_5, y.Kd_Rek90_6    

SELECT CAST(Kd_Rek90_1 AS VARCHAR) + '.' + CAST(Kd_Rek90_2 AS VARCHAR) + '.' + CAST(Kd_Rek90_3 AS VARCHAR) Kd_Rek, 
    '      ' + (SELECT Nm_Rek90_3 FROM Ref_Rek90_3 WHERE Kd_Rek90_1 = a.Kd_Rek90_1 AND Kd_Rek90_2 = a.Kd_Rek90_2 AND Kd_Rek90_3 = a.Kd_Rek90_3) Nm_Rek,
    SUM(Anggaran) Anggaran, SUM(Realisasi) Realisasi, SUM(Anggaran - Realisasi) Sisa, 3 Lvl
FROM   #temp1 a
GROUP BY Kd_Rek90_1, Kd_Rek90_2, Kd_Rek90_3

UNION ALL 

SELECT CAST(Kd_Rek90_1 AS VARCHAR) + '.' + CAST(Kd_Rek90_2 AS VARCHAR) Kd_Rek, 
    '   ' + (SELECT Nm_Rek90_2 FROM Ref_Rek90_2 WHERE Kd_Rek90_1 = a.Kd_Rek90_1 AND Kd_Rek90_2 = a.Kd_Rek90_2) Nm_Rek,
    SUM(Anggaran), SUM(Realisasi), SUM(Anggaran - Realisasi) Sisa, 2
FROM   #temp1 a
GROUP BY Kd_Rek90_1, Kd_Rek90_2

UNION ALL 

SELECT CAST(Kd_Rek90_1 AS VARCHAR) Kd_Rek, 
    (SELECT Nm_Rek90_1 FROM Ref_Rek90_1 WHERE Kd_Rek90_1 = a.Kd_Rek90_1) Nm_Rek,
    SUM(Anggaran), SUM(Realisasi), SUM(Anggaran - Realisasi) Sisa, 1
FROM   #temp1 a
WHERE Kd_Rek90_1 IN (4,5)
GROUP BY Kd_Rek90_1

UNION ALL

SELECT '6', 'PEMBIAYAAN DAERAH', NULL, NULL, NULL, 1

UNION ALL 

SELECT '599' Kd_Rek, 'SURPLUS / DEFISIT', 
    SUM(CASE Kd_Rek90_1 WHEN 4 THEN Anggaran  WHEN 5 THEN -Anggaran END),
    SUM(CASE Kd_Rek90_1 WHEN 4 THEN Realisasi WHEN 5 THEN -Realisasi END), 
    SUM(CASE Kd_Rek90_1 WHEN 4 THEN Anggaran  WHEN 5 THEN -Anggaran END)-
    SUM(CASE Kd_Rek90_1 WHEN 4 THEN Realisasi WHEN 5 THEN -Realisasi END), 1
    
FROM   #temp1 a WHERE Kd_Rek90_1 IN (4,5)

UNION ALL 

SELECT '699' Kd_Rek, 'PEMBIAYAAN NETTO', 
    SUM(CASE Kd_Rek90_2 WHEN 1 THEN Anggaran  WHEN 2
    THEN -Anggaran END),
    SUM(CASE Kd_Rek90_2 WHEN 2 THEN Realisasi WHEN 2 THEN -Realisasi END), 
    SUM(CASE Kd_Rek90_2 WHEN 1 THEN Anggaran-Realisasi  WHEN 2 THEN Realisasi-Anggaran END), 1
FROM   #temp1 a WHERE Kd_Rek90_1 = 6 AND Kd_Rek90_2 IN (1,2)

UNION ALL

SELECT '999' Kd_Rek, 'SILPA', 
    SUM(CASE WHEN Kd_Rek90_1 =4 OR (Kd_Rek90_1 = 6 AND Kd_Rek90_2 = 1) THEN Anggaran ELSE -Anggaran END),
    SUM(CASE WHEN Kd_Rek90_1 =4 OR (Kd_Rek90_1 = 6 AND Kd_Rek90_2 = 1) THEN Realisasi ELSE -Realisasi END),
    SUM(CASE WHEN Kd_Rek90_1 =4 OR (Kd_Rek90_1 = 6 AND Kd_Rek90_2 = 1) THEN Anggaran-Realisasi ELSE Realisasi-Anggaran END), 1
FROM   #temp1 a 

ORDER BY Kd_Rek


DROP TABLE #temp1