# Query Untuk Monitoring Gaji di Database SIMDA

## Menampilkan Pagu Anggaran Per Sub Unit Berdasarkan Data RKA

```
SELECT x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub, y.Nm_Sub_Unit, x.Anggaran
from (
	SELECT  a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub, sum(a.Total) Anggaran
	FROM Ta_Belanja_Rinc_Sub a
	WHERE
		a.Kd_Rek_1=5 and 
		a.Kd_Rek_2=1 AND
		a.Kd_Rek_3=1 AND
	    a.tahun=2021
	GROUP BY a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub
) x JOIN Ref_Sub_Unit y
	on
	y.Kd_Urusan=x.Kd_Urusan and 
	y.Kd_Bidang=x.Kd_Bidang and 
	y.Kd_Unit=x.Kd_Unit and 
	y.Kd_Sub=x.Kd_Sub

ORDER BY x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub
```

## Menampilkan Pagu Anggaran Per Sub Unit Berdasarkan Data APBD (ARSIP)

```
SELECT x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub, y.Nm_Sub_Unit, x.Anggaran
from (
	SELECT  a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub, sum(a.Total) Anggaran
	FROM Ta_rask_arsip a
	WHERE
		a.Kd_Rek_1=5 and 
		a.Kd_Rek_2=1 AND
		a.Kd_Rek_3=1 AND
	    a.Kd_Perubahan=4 AND
	    a.tahun=2021
	GROUP BY a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub
) x JOIN Ref_Sub_Unit y
	on
	y.Kd_Urusan=x.Kd_Urusan and 
	y.Kd_Bidang=x.Kd_Bidang and 
	y.Kd_Unit=x.Kd_Unit and 
	y.Kd_Sub=x.Kd_Sub

ORDER BY x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub
```
**Keterangan:**
- Untuk mengganti dasar data dengan merubah nilai dari kolom a.Kd_Perubahan=4 menyesuikan kode perubahan. 3=PRA RKA, 4=APBD, 5=Pergeseran APBD, 6=Perubahan APBD
- Tambah filter tahun=2021 untuk memastikan hanya menampilkan tahun anggaran yang sudah dipilih

## Menampilkan Realisasi Gaji Per Bulan

```
SELECT x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub, y.Nm_Sub_Unit, x.Anggaran
from (
	SELECT  a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub, sum(a.nilai) Anggaran
	FROM ta_spm_rinc a
		left join ta_spm p ON a.no_spm=p.no_spm
		right join ta_sp2d s ON a.no_spm=s.no_spm
	WHERE
		a.Kd_Rek_1=5 and 
		a.Kd_Rek_2=1 AND
		a.Kd_Rek_3=1 AND
		a.tahun=2021 AND
		p.jn_spm=3 AND
		s.tgl_sp2d between '2021/01/01 00:00:00' and '2021/01/31 00:00:00'
	GROUP BY a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub
) x JOIN Ref_Sub_Unit y
	on
	y.Kd_Urusan=x.Kd_Urusan and 
	y.Kd_Bidang=x.Kd_Bidang and 
	y.Kd_Unit=x.Kd_Unit and 
	y.Kd_Sub=x.Kd_Sub

ORDER BY x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub
```
**Keterangan:**
- Untuk merubah nilai bulan dengan mengganti nilai dari kolom s.tgl_sp2d between '2021/01/01 00:00:00' and '2021/01/31 00:00:00' menyesuikan rentang waktu yang diinginkan.

## Menampilkan Realisasi Akumulasi Gaji Keseluruhan

```
SELECT x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub, y.Nm_Sub_Unit, x.Anggaran
from (
	SELECT  a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub, sum(a.nilai) Anggaran
	FROM ta_spm_rinc a
		left join ta_spm p ON a.no_spm=p.no_spm
		right join ta_sp2d s ON a.no_spm=s.no_spm
	WHERE
		a.Kd_Rek_1=5 and 
		a.Kd_Rek_2=1 AND
		a.Kd_Rek_3=1 AND
		a.tahun=2021 AND
		p.jn_spm=3
	GROUP BY a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub
) x JOIN Ref_Sub_Unit y
	on
	y.Kd_Urusan=x.Kd_Urusan and 
	y.Kd_Bidang=x.Kd_Bidang and 
	y.Kd_Unit=x.Kd_Unit and 
	y.Kd_Sub=x.Kd_Sub

ORDER BY x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub
```
**Keterangan:**
- Sebaiknya ditambahkan filter tahun anggaran untuk memastikan akumulasi anggaran sesuai dengan tahun anggaran yang diinginkan.


## Menampilkan Realisasi Akumulasi Gaji Keseluruhan dengan nomor SPM dan uraiannya

```
SELECT x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub, y.Nm_Sub_Unit, x.no_spm, x.uraian, x.Anggaran
from (
	SELECT  a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.no_spm, a.Kd_Sub, p.uraian, sum(a.nilai) Anggaran
	FROM ta_spm_rinc a
		left join ta_spm p ON a.no_spm=p.no_spm
		right join ta_sp2d s ON a.no_spm=s.no_spm
	WHERE
		a.Kd_Rek_1=5 and 
		a.Kd_Rek_2=1 AND
		a.Kd_Rek_3=1 AND
		a.tahun=2021 AND
		p.jn_spm=3 AND
                s.no_spm is not null
	GROUP BY a.Kd_Urusan, a.Kd_Bidang, a.Kd_Unit, a.Kd_Sub, a.no_spm, p.uraian
) x JOIN Ref_Sub_Unit y
	on
	y.Kd_Urusan=x.Kd_Urusan and 
	y.Kd_Bidang=x.Kd_Bidang and 
	y.Kd_Unit=x.Kd_Unit and 
	y.Kd_Sub=x.Kd_Sub

ORDER BY x.Kd_Urusan, x.Kd_Bidang, x.Kd_Unit, x.Kd_Sub
```
**Keterangan:**
- Sebaiknya ditambahkan filter tahun anggaran untuk memastikan akumulasi anggaran sesuai dengan tahun anggaran yang diinginkan.
