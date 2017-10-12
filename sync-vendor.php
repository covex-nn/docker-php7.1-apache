#!/usr/local/bin/php -dphar.readonly=0
<?php

$source = '/composer/vendor';
$target = '/srv/.sync';

if (is_file($target) && !is_dir($target)) {
  unlink($target);
}
if (!file_exists($target)) {
  mkdir($target, true);
}
if (file_exists($source) && is_dir($source)) {
  foreach (new DirectoryIterator($source) as $dir) {
    /* @var $dir DirectoryIterator */
    if (!$dir->isDot() && $dir->isDir()) {
      $pharName = $dir->getFilename();
      if (in_array($pharName, ["bin"])) {
        continue;
      }
      $pharAlias = $pharName . ".phar";
      $pharFilename = $target . "/" . $pharAlias;

      $phar = new Phar($pharFilename);
      try {
        $phar->buildFromDirectory($dir->getPathname());
        echo "Synced vendor $pharAlias\n";
      } catch (Exception $exception) {
        echo "Could not sync vendor $pharAlias: " . $exception->getMessage() . "\n";
      }
    }
  }
}
