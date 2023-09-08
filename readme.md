
## BGGP4 Windows Batch and PHP Polyglot in 99 Bytes

Writeup for an entry to: https://binary.golf/

### The code

bggp.bat:
```
@echo off
type %0>4&&echo.4&&exit /b 4
<?php ob_end_clean();copy(__FILE__,"4");echo "4\n";die(4);
```

Use Windows (CRLF) line endings in bggp.bat

### How to run as Windows Batch

Note: The following instructions have commands preceded by "\> ", when running the commands omit this part

Open the Command Prompt and CD to the directory containing bggp.bat

- Run as batch:  
  \> `call bggp.bat`
- Check return code:  
  \> `echo %errorlevel%`
- Check that the file "4" was created:  
  \> `dir`
- Get sha256:  
  \> `powershell -Command "Get-FileHash *"`
- Remove the file "4" when done:  
  \> `del 4`

### How to run as PHP

Download the Thread Safe Zip that is appropriate for your platform (x86 or x64) from: https://windows.php.net/download  
Example: https://windows.php.net/downloads/releases/php-8.2.10-Win32-vs16-x64.zip  
Extract the contents of the zip to a directory, example: C:\php  
In the php directory, copy the file "php.ini-production" to "php.ini"

- Add php directory to path environmental variable:  
  \> `set "path=C:\php;%path%"`
- Run as php:  
  \> `php -r "ob_start();include 'bggp.bat';"`
- Check return code:  
  \> `echo %errorlevel%`
- Check that the file "4" was created:  
  \> `dir`
- Get sha256:  
  \> `powershell -Command "Get-FileHash *"`
- Remove the file "4" when done:  
  \> `del 4`

### How the Batch works

The first two lines are in Batch. `@echo off` prevents command from being displayed while running. The second line is three commands combined with conditional execution operators (&&). `type %0>4` takes the name of the currently executing batch file (%0), uses the "type" command to get the file contents, and redirects the output (\>4) to a file named "4". Normally the "copy" command would be used, but it would confirm overwriting the file "4" if it already existed as well as displaying a "1 file(s) copied." message. This behavior could be changed by using the /y parameter and redirecting the output to nul, but would result in a longer command than using type: `copy /y %0 4 \>nul`, so to minimize size I used the type command. `echo.4` displays the number 4. `exit /b 4` causes the batch file to exit with the return code 4, but not close the window when you use `call bggp.bat` to run it, and also has the side effect of causing any following lines to be ignored.

### How the PHP works

The third line is in PHP, but the code really starts in the command used to run it. In the command `php -r "ob_start();include 'bggp.bat';"` the function `ob_start();` is used to enable output buffering, and `include 'bggp.bat';` is used to evaluate the code in "bggp.bat". The batch code in the first two lines would normally be displayed, but since output buffering is enabled it is saved to an output buffer. The beginning of the third line `<?php` is the PHP opening tag. The function `ob_end_clean();` clears the output buffer and turns off output buffering, which clears the batch code so it is not displayed. The next part `copy(__FILE__,"4");`, copies the currently executing script file (__FILE__) to a file named "4". The "echo" language construct is used to display 4, followed by a new line to mirror the behavior of batch. The "die" language construct is used to exit the php script with the return code of 4.
