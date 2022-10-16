<?php

$ex = array_map('strtolower', get_loaded_extensions());
$ex[] = 'fpm';

echo 'Total: ', count($ex), "\n";

sort($ex);
foreach (array_chunk($ex, 4) as $ee) {
    foreach ($ee as $e) {
        echo '- ' . str_pad($e, 18, ' ', STR_PAD_RIGHT);
    }
    echo "\n";
}
