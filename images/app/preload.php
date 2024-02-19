<?php
$directory = new RecursiveDirectoryIterator('/var/www');
$fullTree = new RecursiveIteratorIterator($directory);
$phpFiles = new RegexIterator($fullTree, '/.+((?<!Test)+\.php$)/i', RecursiveRegexIterator::GET_MATCH);

echo "Precompile php files:\n"; 
foreach ($phpFiles as $key => $file) {
    echo "  ", $file[0], "\n";
    opcache_compile_file($file[0]);
}
?>