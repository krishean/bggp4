@echo off
type %0>4&&echo.4&&exit /b 4
<?php ob_end_clean();copy(__FILE__,"4");echo "4\n";die(4);