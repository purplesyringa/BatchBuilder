// Resize
var width = 100;
var height = 40;

resizeTo(width, height);
moveTo(
	Math.random() * (screen.width - width),
	Math.random() * (screen.height - height)
);

// Handle blur
if(!document.hasFocus()) {
	var sh = new ActiveXObject("WScript.Shell");
	sh.Run("cmd /c start \"\" mshta " + hta.commandLine, 0, true);
	close();
}

// Set color
var color = "#";
for(var i = 0; i < 3; i++) {
	var p = Math.floor((Math.random() * 256)).toString(16);
	if(p.length == "1") {
		p = "0" + p;
	}

	color += p;
}

document.getElementById("body").style.color = color;