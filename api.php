<?php
include 'config.php';

$ret = array(
	'error'	=> 1,
	'msg'	=> ':)',
	'post'	=> array()
);
if(empty($_POST)){
	die(json_encode($ret));
}else{
	$ret['post'] = $_POST;
}
if(empty($_POST['api_key']) || $_POST['api_key'] != APIKEY){
	$ret['msg'] = 'APIKEY salah!';
	die(json_encode($ret));
}
if(empty($_POST['query'])){
	$ret['msg'] = 'Query tidak boleh kosong';
	die(json_encode($ret));
}
$dbh = new PDO ("mysql:host=".HOST_SQL.";dbname=".DB_SQL, USER_SQL, PASS_SQL);

if(!empty($_POST['db'])){
	$sql = '
		SELECT 
			d.* 
		FROM database_simda d 
		where d.nama=?';
	$stmt = $dbh->prepare($sql);
	$stmt->execute(array($_POST['db']));
	$data = $stmt->fetchAll(\PDO::FETCH_ASSOC); 
}else{
	$sql = '
		SELECT 
			d.* 
		FROM database_simda d 
		where d.tahun=?';
	$stmt = $dbh->prepare($sql);
	$stmt->execute(array($_POST['tahun']));
	$data = $stmt->fetchAll(\PDO::FETCH_ASSOC); 
}

if(empty($data)){
	$ret['error'] = 1;
	$ret['msg'] = 'Database tidak ditemukan';
	die(json_encode($ret));
}

// print_r($data); die();
$dbname   = $data[0]['nama'];
$hostname = "mssql";
$username = $data[0]['username'];
$pw       = $data[0]['password'];
$connection = "odbc:DRIVER=".DRIVER.";SERVERNAME=$hostname;DATABASE=$dbname";
// print_r($connection); die();

$dbh      = new PDO($connection, $username, $pw);
try {
	$stmt = $dbh->prepare($_POST['query']);
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

$ret['query'] = $_POST['query'];
$ret['db'] = $dbname;
die(json_encode($ret));
