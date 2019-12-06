<?php

$fm['tempdir'] = '/tmp';
$fm['mkdperm'] = 755;

$pathToExternals = [
    'zip' => '/usr/bin/zip',
    'unzip' => '/usr/bin/unzip',
    'tar' => '/bin/tar',
    'gzip' => '/bin/gzip',
    'rar' => '/usr/bin/unrar'
];

$fm['archive']['types'] = array('rar', 'zip', 'tar', 'gzip', 'bzip2');
$fm['archive']['compress'][0] = range(0, 5);
$fm['archive']['compress'][1] = array('-0', '-1', '-9');
$fm['archive']['compress'][2] = $fm['archive']['compress'][3] = $fm['archive']['compress'][4] = array(0);
