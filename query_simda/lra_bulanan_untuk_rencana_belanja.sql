-- Ambil data LRA untuk bahan rencana realisasi bulanan
-- Kalo ada pertanyaan mohon ditanyakan di grup. Biar yang lain juga tau + ada yang bantu jawab
--
-- Petunjuk pake :
-- Bisa dieksekusi pake editor query bawaan Sql Server setelah ganti tanggal...
-- use it wisely bro...

-- by huda.salam@gmail.com

IF OBJECT_ID('#tempLraBelanja') IS NOT NULL 
    DROP TABLE #tempLraBelanja
GO
    
DECLARE @tgl DATETIME
SELECT @tgl = '2021/01/31' --################ GANTI TANGGAL SESUAI BULAN

SELECT Bulan, y.Kd_Rek90_1, y.Kd_Rek90_2, y.Kd_Rek90_3, y.Kd_Rek90_4, y.Kd_Rek90_5, y.Kd_Rek90_6, 
    SUM(Realisasi) Realisasi, 5 Lvl INTO #tempLraBelanja
FROM (
    SELECT  Month(a.Tgl_SP2D) Bulan, Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Nilai Realisasi
    FROM    Ta_SP2D a
    INNER JOIN Ta_SPM b ON a.No_SPM = b.No_SPM AND a.Tahun = b.Tahun
    INNER JOIN Ta_SPM_Rinc c ON c.No_SPM = b.No_SPM AND c.Tahun = b.Tahun
    WHERE   b.Jn_SPM IN (2,3,5)
    AND     a.Tgl_SP2D <= @tgl 
    
    UNION ALL
    
    SELECT  Month(a.Tgl_Bukti) Bulan, Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, CASE WHEN D_K = 'D' THEN Nilai ELSE -Nilai END Realisasi
    FROM    Ta_Penyesuaian a
    INNER JOIN Ta_Penyesuaian_Rinc b ON a.Tahun = b.Tahun AND a.No_Bukti = b.No_Bukti
    WHERE a.Jns_P1 = 1 AND a.Jns_P2 = 3
    AND     a.Tgl_Bukti <= @tgl AND b.Kd_Rek_1 = 5
    
    UNION ALL
    
    SELECT Month(a.Tgl_SP2B) Bulan, Kd_Rek_1, Kd_Rek_2, Kd_Rek_3, Kd_Rek_4, Kd_Rek_5, Nilai Realisasi
    FROM   Ta_SP2B a
    INNER JOIN Ta_SP3B b ON a.Tahun = b.Tahun AND a.No_SP3B = b.No_SP3B
    INNER JOIN Ta_SP3B_Rinc c  ON c.Tahun = b.Tahun AND c.No_SP3B = b.No_SP3B
    WHERE  a.Tgl_SP2B <= @tgl AND c.Kd_Rek_1 = 5
) x
INNER JOIN Ref_Rek_Mapping y ON x.Kd_Rek_1 = y.Kd_Rek_1 AND x.Kd_Rek_2 = y.Kd_Rek_2 AND x.Kd_Rek_3 = y.Kd_Rek_3 AND 
    x.Kd_Rek_4 = y.Kd_Rek_4 AND x.Kd_Rek_5 = y.Kd_Rek_5
GROUP BY y.Kd_Rek90_1, y.Kd_Rek90_2, y.Kd_Rek90_3, y.Kd_Rek90_4, y.Kd_Rek90_5, y.Kd_Rek90_6, Bulan    

select a.kd_rek90_1, a.kd_rek90_2, a.kd_rek90_3, 0 kd_rek90_4,
	a.nm_rek90_3,
	coalesce(sum(case bulan when 1 then realisasi else 0 end), 0) Jan, 
	coalesce(sum(case bulan when 2 then realisasi else 0 end), 0) Feb,
	coalesce(sum(case bulan when 3 then realisasi else 0 end), 0) Mar,
	coalesce(sum(case bulan when 4 then realisasi else 0 end), 0) Apr,
	coalesce(sum(case bulan when 5 then realisasi else 0 end), 0) Mei,
	coalesce(sum(case bulan when 6 then realisasi else 0 end), 0) Jun,
	coalesce(sum(case bulan when 7 then realisasi else 0 end), 0) Jul,
	coalesce(sum(case bulan when 8 then realisasi else 0 end), 0) Agu,
	coalesce(sum(case bulan when 9 then realisasi else 0 end), 0) Sep,
	coalesce(sum(case bulan when 10 then realisasi else 0 end), 0) Okt,
	coalesce(sum(case bulan when 11 then realisasi else 0 end), 0) Nop,
	coalesce(sum(case bulan when 12 then realisasi else 0 end), 0) Des
from ref_rek90_3 a
 left join #tempLraBelanja b
 on a.kd_rek90_1 = b.kd_rek90_1 
	and a.kd_rek90_2 = b.kd_rek90_2 
	and a.kd_rek90_3 = b.kd_rek90_3 
where a.kd_rek90_1 = 5 and a.kd_rek90_2 <> 4
group by a.kd_rek90_1, a.kd_rek90_2, a.kd_rek90_3, a.nm_rek90_3

union all

select a.kd_rek90_1, a.kd_rek90_2, a.kd_rek90_3, 
	case 
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 <= 4 then 1
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 = 5 then 2
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 = 6 then 3
		else a.kd_Rek90_4 end
	,
	case 
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 <= 4 then 'Belanja Bantuan Keuangan ke Pemda Lainnya'
		else a.Nm_Rek90_4 end nm_rek90_4,
	coalesce(sum(case bulan when 1 then realisasi else 0 end), 0) Jan, 
	coalesce(sum(case bulan when 2 then realisasi else 0 end), 0) Feb,
	coalesce(sum(case bulan when 3 then realisasi else 0 end), 0) Mar,
	coalesce(sum(case bulan when 4 then realisasi else 0 end), 0) Apr,
	coalesce(sum(case bulan when 5 then realisasi else 0 end), 0) Mei,
	coalesce(sum(case bulan when 6 then realisasi else 0 end), 0) Jun,
	coalesce(sum(case bulan when 7 then realisasi else 0 end), 0) Jul,
	coalesce(sum(case bulan when 8 then realisasi else 0 end), 0) Agu,
	coalesce(sum(case bulan when 9 then realisasi else 0 end), 0) Sep,
	coalesce(sum(case bulan when 10 then realisasi else 0 end), 0) Okt,
	coalesce(sum(case bulan when 11 then realisasi else 0 end), 0) Nop,
	coalesce(sum(case bulan when 12 then realisasi else 0 end), 0) Des
from ref_rek90_4 a
 left join #tempLraBelanja b
 on a.kd_rek90_1 = b.kd_rek90_1 
	and a.kd_rek90_2 = b.kd_rek90_2 
	and a.kd_rek90_3 = b.kd_rek90_3 
	and a.kd_rek90_4 = b.kd_rek90_4 
where a.kd_rek90_1 = 5 and a.kd_rek90_2 = 4
group by a.kd_rek90_1, a.kd_rek90_2, a.kd_rek90_3,	case 
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 <= 4 then 1
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 = 5 then 2
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 = 6 then 3
		else a.kd_Rek90_4 end,
		case 
		when a.kd_rek90_3 = 2 and a.kd_rek90_4 <= 4 then 'Belanja Bantuan Keuangan ke Pemda Lainnya'
		else a.Nm_Rek90_4 end

UNION ALL

SELECT 5,4,1,3,'Belanja Bagi Hasil Pendapatan Lainnya',0,0,0,0,0,0,0,0,0,0,0,0

UNION ALL

SELECT 5,2,6,0,'Belanja Modal Aset Lainnya',0,0,0,0,0,0,0,0,0,0,0,0

order by a.kd_rek90_1, a.kd_rek90_2, a.kd_rek90_3, a.kd_rek90_4 

DROP TABLE #tempLraBelanja
