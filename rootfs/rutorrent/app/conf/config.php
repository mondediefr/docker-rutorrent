<?php

// configuration parameters
@define('HTTP_USER_AGENT', 'Mozilla/5.0 (Windows NT 6.0; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0', true);
@define('HTTP_TIME_OUT', 30, true); // in seconds
@define('HTTP_USE_GZIP', true, true);
@define('RPC_TIME_OUT', 5, true); // in seconds
@define('LOG_RPC_CALLS', false, true);
@define('LOG_RPC_FAULTS', true, true);
@define('PHP_USE_GZIP', false, true);
@define('PHP_GZIP_LEVEL', 2, true);

$httpIP = null; // IP string. Or null for any.
$httpProxy = [
    'use' => false,
    'proto' => 'http', // 'http' or 'https'
    'host' => 'PROXY_HOST_HERE',
    'port' => 3128
];
$schedule_rand = 10; // rand for schedulers start, +0..X seconds
$do_diagnostic = true;
$log_file = '/tmp/errors.log'; // path to log file (comment or leave blank to disable logging)
$saveUploadedTorrents = true; // Save uploaded torrents to profile/torrents directory or not
$overwriteUploadedTorrents = false; // Overwrite existing uploaded torrents in profile/torrents directory or make unique name
$topDirectory = '/data/downloads'; // Upper available directory. Absolute path with trail slash.
$forbidUserSettings = false;
$scgi_port = 0;
$scgi_host = 'unix:///run/rtorrent/rtorrent.sock';
$XMLRPCMountPoint = '/RPC';
$pathToExternals = [
    'php' => '/usr/bin/php7',
    'curl' => '/usr/bin/curl',
    'gzip' => '/usr/bin/gzip',
    'id' => '/usr/bin/id',
    'stat' => '/usr/bin/stat',
    'pgrep' => '/usr/bin/pgrep',
    'python' => '/usr/bin/python3'
];
$localhosts = [
    '127.0.0.1',
    'localhost'
];
$profilePath = '../share'; // Path to user profiles
$profileMask = 0777;
$tempDirectory = null; // Temp directory. Absolute path with trail slash. If null, then autodetect will be used.
$canUseXSendFile = false; // If true then use X-Sendfile feature if it exist
$locale = 'UTF8';
