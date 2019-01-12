var minSize=8;
var maxSize=18;
var deaultSize=10;
function changeFontSize(ident, change) 
{
	var s = deaultSize;
 	var element = document.getElementsById(ident);
	for(var i=0;i<element.length;i++) 
	{
		if(element[i].style.fontSize)
		{
			s = parseInt(element[i].style.fontSize.replace("px",""));
		}

		switch (change) 
		{
			case 'inc':
				if(s!=maxSize) { s += 1; }
				break;
			case 'dec':
				if(s!=minSize) { s -= 1; }
				break;
			default:
				s = deaultSize;
				break;
		}

		element[i].style.fontSize = s+"px";
	}
}
