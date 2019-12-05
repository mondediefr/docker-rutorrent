<?php

$fm = [
    'tempdir' => '/tmp', // path were to store temporary data ; must be writable
    'mkdperm' => 755, // default permission to set to new created directories
    'archive' => [
        'types' => ['zip', 'tar', 'gzip', 'bzip2'],
        'compress' => [
            range(0, 5),
            ['-0', '-1', '-9'],
            array(0),
            array(0),
            array(0)
        ]
    ]
];

$pathToExternals = [
    'zip' => '/usr/bin/zip',
    'unzip' => '/usr/bin/unzip',
    'tar' => '/bin/tar',
    'gzip' => '/bin/gzip',
    'bzip2' => '/usr/bin/bzip2'
];
