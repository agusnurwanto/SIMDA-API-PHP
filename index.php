<?php
include 'config.php';

if(empty($_GET) & empty($_GET['db'])){
	die('Tambahkan param GET ?db=namadb di belakang url ini untuk testing koneksi SQL Server! :)');
}
$ret = array(
	'error'	=> 1,
	'msg'	=> ':)',
	'post'	=> array()
);


$dbh = new PDO ("mysql:host=".HOST_SQL.";dbname=".DB_SQL, USER_SQL, PASS_SQL);
$sql = '
	SELECT 
		d.* 
	FROM database_simda d 
	where d.nama=?';
$stmt = $dbh->prepare($sql);
$stmt->execute(array($_GET['db']));
$data = $stmt->fetchAll(\PDO::FETCH_ASSOC); 

if(empty($data)){
	$ret['error'] = 1;
	$ret['msg'] = 'Database tidak ditemukan';
	die(json_encode($ret));
}

// print_r($data); die();
$dbname   = $data[0]['nama'];
$hostname = $data[0]['hostname'];
$username = $data[0]['username'];
$pw       = $data[0]['password'];


if(DRIVER){
	if(DRIVER == 'odbc'){
		$connection = "odbc:".$hostname;
	}else{
		$connection = "odbc:DRIVER=".DRIVER.";SERVERNAME=$hostname;DATABASE=$dbname";
	}
}else{
	$connection = "sqlsrv:Server=$hostname;DATABASE=$dbname;";
	if(TRUST_SERVER_CERTIFICATE) {
		$connection .= "TrustServerCertificate=true;";
	}
}
// print_r($connection); die();

$dbh      = new PDO($connection, $username, $pw);

if(DRIVER && DRIVER=='odbc'){
	$dbh->exec('USE '.$dbname);
}


$query = 'select tahun,LastDBAplVer from ref_setting';
try {
	$stmt = $dbh->prepare($query);
	$stmt->execute();
	$check_error = $stmt->errorInfo();
	if(!empty($check_error[1])){
		$ret['error'] = 1;
		$ret['msg'] = json_encode($check_error);
	}else{
		$data = array();
		while ($row = $stmt->fetch()) {
		    $data[] = $row;
		}
		$ret['error'] = 0;
		$ret['msg'] = $data;
	}
}catch(PDOException $e){
	$ret['error'] = 1;
	$ret['msg'] = $e->getMessage();
}

$ret['query'] = $query;
$ret['db'] = $dbname;
die(json_encode($ret));
