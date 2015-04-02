<?php

if(isset($_POST['source']))
{
file_put_contents('index.html', $_POST['source']);
}
print("<html><head><meta http-equiv='refresh' content='0; url=http://yalp.asuscomm.com/code/cryptomissive/' /> </head></html>");

?>
