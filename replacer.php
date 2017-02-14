<?php

if(isset($_POST['source']))
{
file_put_contents('/var/www/cryptomissive/index.html', $_POST['source']);
}
print("<html><head><meta http-equiv='refresh' content='0; url=http://yalp.asuscomm.com/cryptomissive/' /> </head></html>");

?>
