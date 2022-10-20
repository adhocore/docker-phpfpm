<?php

$ex = array_map('strtolower', get_loaded_extensions());
$ex = array_merge($ex, ['fpm', 'xdebug']);

echo sprintf('PHP %s, Total extensions: %d', PHP_VERSION, count($ex)), "\n";

sort($ex);
foreach (array_chunk($ex, 4) as $ee) {
    foreach ($ee as $e) {
        echo '- ' . str_pad($e, 18, ' ', STR_PAD_RIGHT);
    }
    echo "\n";
}
