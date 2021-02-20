-- Ambil data LRA untuk bahan rencana realisasi bulanan
-- Kalo ada pertanyaan mohon ditanyakan di grup. Biar yang lain juga tau + ada yang bantu jawab
--
-- Petunjuk pake :
-- Bisa dieksekusi pake editor query bawaan Sql Server setelah ganti tanggal. Sql ini akan ambil data anggaran kas
-- terakhir sebelum @tgl. sistem perubahan perda perbup di Simda terbatas, akibatnya ada kalanya data anggaran / 
-- anggaran kas ditindas. komunikasikan dengan yg handel anggaran...

-- last but not least, use it wisely bro...

-- by huda.salam@gmail.com

declare @tgl datetime
set @tgl = '2021/01/31' ---- ########## GANTI TANGGAL
select c.kd_rek90_1, c.kd_rek90_2, c.kd_rek90_3, 0 kd_rek90_4,
	c.nm_rek90_3,
	coalesce(sum(jan), 0) Jan, 
	coalesce(sum(feb), 0) Feb,
	coalesce(sum(mar), 0) Mar,
	coalesce(sum(apr), 0) Apr,
	coalesce(sum(mei), 0) Mei,
	coalesce(sum(jun), 0) Jun,
	coalesce(sum(jul), 0) Jul,
	coalesce(sum(agt), 0) Agu,
	coalesce(sum(sep), 0) Sep,
	coalesce(sum(okt), 0) Okt,
	coalesce(sum(nop), 0) Nop,
	coalesce(sum(des), 0) Des
from ref_rek90_3 c left join ref_rek_mapping b 
 on b.kd_rek90_1 = c.kd_rek90_1 
	and b.kd_rek90_2 = c.kd_rek90_2 
	and b.kd_rek90_3 = c.kd_rek90_3 
	
 left join (select * from ta_rencana_arsip where kd_perubahan = (select max(kd_perubahan) from ta_rask_arsip_perubahan where tgl_perda <= @tgl)) a
 on a.kd_rek_1 = b.kd_rek_1 
	and a.kd_rek_2 = b.kd_rek_2 
	and a.kd_rek_3 = b.kd_rek_3 
	and a.kd_rek_4 = b.kd_rek_4
	and a.kd_rek_5 = b.kd_rek_5
where c.kd_rek90_1 = 5 and c.kd_rek90_2 <> 4
group by c.kd_rek90_1, c.kd_rek90_2, c.kd_rek90_3, c.nm_rek90_3

union all

select c.kd_rek90_1, c.kd_rek90_2, c.kd_rek90_3, 
	case 
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 <= 4 then 1
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 = 5 then 2
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 = 6 then 3
		else c.kd_Rek90_4 end
	,
	case 
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 <= 4 then 'Belanja Bantuan Keuangan ke Pemda Lainnya'
		else c.Nm_Rek90_4 end nm_rek90_4,
	coalesce(sum(jan), 0),
	coalesce(sum(feb), 0),
	coalesce(sum(mar), 0),
	coalesce(sum(apr), 0),
	coalesce(sum(mei), 0),
	coalesce(sum(jun), 0),
	coalesce(sum(jul), 0),
	coalesce(sum(agt), 0),
	coalesce(sum(sep), 0),
	coalesce(sum(okt), 0),
	coalesce(sum(nop), 0),
	coalesce(sum(des), 0)
from ref_rek90_4 c left join ref_rek_mapping b 
 on b.kd_rek90_1 = c.kd_rek90_1 
	and b.kd_rek90_2 = c.kd_rek90_2 
	and b.kd_rek90_3 = c.kd_rek90_3 
	and b.kd_rek90_4 = c.kd_rek90_4
 left join (select * from ta_rencana_arsip where kd_perubahan = (select max(kd_perubahan) from ta_rask_arsip_perubahan where tgl_perda <= @tgl)) a
 on a.kd_rek_1 = b.kd_rek_1 
	and a.kd_rek_2 = b.kd_rek_2 
	and a.kd_rek_3 = b.kd_rek_3 
	and a.kd_rek_4 = b.kd_rek_4
	and a.kd_rek_5 = b.kd_rek_5
where c.kd_rek90_1 = 5 and c.kd_rek90_2 = 4
group by c.kd_rek90_1, c.kd_rek90_2, c.kd_rek90_3,	case 
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 <= 4 then 1
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 = 5 then 2
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 = 6 then 3
		else c.kd_Rek90_4 end,
		case 
		when c.kd_rek90_3 = 2 and c.kd_rek90_4 <= 4 then 'Belanja Bantuan Keuangan ke Pemda Lainnya'
		else c.Nm_Rek90_4 end

UNION ALL

SELECT 5,4,1,3,'Belanja Bagi Hasil Pendapatan Lainnya',0,0,0,0,0,0,0,0,0,0,0,0

UNION ALL

SELECT 5,2,6,0,'Belanja Modal Aset Lainnya',0,0,0,0,0,0,0,0,0,0,0,0

order by c.kd_rek90_1, c.kd_rek90_2, c.kd_rek90_3, c.kd_rek90_4 
