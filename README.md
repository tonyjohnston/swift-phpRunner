## swift-phpRunner
Run PHP scripts in a native macOS app

### What is this?
Sample code for running PHP scripts inside a macOS app. Has a very simple and basic UI consisting of a split scroll view and a button. 

### Functionality
Enter PHP code in the top view and see results in the bottom view. 

### Uses macOS default PHP. 
For simple protability, uses default PHP binary included with macOS. However, it is possible to embed a PHP binary, custom `php.ini` file, and PHP extensions.

#### From PHP documentation:
> You can specify the php.ini file in command line by using the following syntax:<br/>
> `php -c [Path to php.ini file] [Path to .php file]`

#### For example:
`php -c /etc/php-alt/php.ini /var/www/public_html/example.php`<br/>
Now the `example.php` file will run with the configuration set in the `php.ini` file located here: `/etc/php-alt/`

#### So:
Add `-c` to the `NSTask` arguments list:
> `arguments.append("-c")`

Add your custom PHP binary's bundle path to the arguments list:
> `let path = Bundle.main.path(forResource: "php",ofType:nil)`

### Additional functionality.

You'll have to figure out how to set the paths used for extenstions in php.ini separately, but send me a note if you have a solution I can include here. Would be interesting to get xdebug output.

Also, php errors go to the Xcode console log. Would be fun to display them in the app.

## Credits
NSTask functionality cribbed with comments from:
https://www.raywenderlich.com/125071/nstask-tutorial-os-x

Syntax highlighting from the super simple and bare bones Macaw:
https://github.com/kuyawa/Macaw

And this is a much simplified version of something I put together in Objective-C many years ago:
http://www.harikari.com/technology/how-to-run-php-scripts-in-xcode-mac-os-x-application.html
