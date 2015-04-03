function useMakeFile()
{
    makeFile(document.getElementById('inputArea').value,document.getElementById('pass').value); document.getElementById("submission").submit();
}
function makeFile(messageIn, key)
{
    console.log("makefile called.");
   message = '<div id = "message">' + messageIn+ '</div>'+
'<form action="replacer.php", id="submission" method="post">'+
'<textarea id="inputArea" rows="4" cols="52" name="source" required></textarea></form>Key:<input type="password" id="pass"><input type="button" onclick="useMakeFile()" value="Send"><div id="messages"></div><div id=""><progress max="100" value="45" id="progress"></progress></div>';
    var source = '';
    var checksum = make_checksum(key);
    var ciphertext = encrypt(message, key);
    var fullPage = '<html>' + document.documentElement.innerHTML + '</html>';
    var substr = fullPage.substring(0,fullPage.indexOf("id=\"password_signature\">"));
    source += substr;
    source += "id=\"password_signature\">" + checksum;
    fullPage = fullPage.substring(fullPage.indexOf("id=\"password_signature\">"));
    fullPage = fullPage.substring(fullPage.indexOf("</scr"+"ipt>"));
    substr = fullPage.substring(0,fullPage.indexOf("id=\"ciphertext\">"));
    source += substr + "id=\"ciphertext\">" + ciphertext;
    fullPage = fullPage.substring(fullPage.indexOf("id=\"ciphertext\">"));
    fullPage = fullPage.substring(fullPage.indexOf("</scr"+"ipt>"));
    source += fullPage;
    document.getElementById("inputArea").value = source;
    alert("Message Sumbitted.");
}