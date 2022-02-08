<?php

global $pathToExternals;
// set with fullpath to binary or leave empty
// $pathToExternals['rar'] = ''; # Not compatible with alpine image
$pathToExternals['7zip'] = '/usr/bin/7z';

$config['mkdperm'] = 755; // default permission to set to new created directories
$config['show_fullpaths'] = false; // wheter to show userpaths or full system paths in the UI

$config['textExtensions'] = 'log|txt|nfo|sfv|xml|html';

// see what 7zip extraction supports as type by file extension
$config['fileExtractExtensions'] = '7z|bzip2|t?bz2|tgz|gz(ip)?|iso|img|lzma|rar|tar|t?xz|zip|z01|wim';

// archive creation, see archiver man page before editing
// archive.fileExt -> config
$config['archive']['type'] = [
    // 'rar' => [
    //     'bin' => 'rar',
    //     'compression' => [0, 3, 5],
    // ],
    '7z' => [
        'bin' => '7zip',
        'compression' => [1, 5, 9],
    ]];

$config['archive']['type']['zip'] = $config['archive']['type']['7z'];
$config['archive']['type']['tar'] = $config['archive']['type']['7z'];
$config['archive']['type']['tar']['has_password'] = false;
$config['archive']['type']['bz2'] = $config['archive']['type']['tar'];
$config['archive']['type']['gz'] = $config['archive']['type']['tar'];
$config['archive']['type']['tar.7z'] = $config['archive']['type']['tar'];
$config['archive']['type']['tar.bz2'] = $config['archive']['type']['tar'];
$config['archive']['type']['tar.gz'] = $config['archive']['type']['tar'];
$config['archive']['type']['tar.xz'] = $config['archive']['type']['tar'];


// multiple passes for archiving and compression
$config['archive']['type']['tar.gz']['multipass'] = ['tar', 'gzip'];
$config['archive']['type']['tar.bz2']['multipass'] = ['tar', 'bzip2'];
$config['archive']['type']['tar.7z']['multipass'] = ['tar', '7z'];
$config['archive']['type']['tar.xz']['multipass'] = ['tar', 'xz'];
