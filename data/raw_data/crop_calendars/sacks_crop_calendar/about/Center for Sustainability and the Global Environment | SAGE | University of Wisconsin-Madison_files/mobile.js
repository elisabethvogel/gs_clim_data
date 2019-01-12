	function showHide() {
		var nl = document.getElementById("navLinks");
		var ht = document.getElementById("headerTools");
		var snl = document.getElementById("subnavLinks");
		var p = nl.style.left;

		if (snl) {
			snl.style.left = '-5000px'; // hide subnav
		}

		switch (p) {
			case "" :
				nl.style.left = '0px';
				ht.style.left = '0px';
				break;
			case "-5000px" :
				nl.style.left = '0px';
				ht.style.left = '0px';
				break;
			case "0px" :
				nl.style.left = '-5000px';
				ht.style.left = '-5000px';
				break;
		}
	}

	function showHideSub() {
		var sn = document.getElementById("subnav");
		var nl = document.getElementById("navLinks");
		var ht = document.getElementById("headerTools");
		var p = $("#subnav").css('display');

		nl.style.left = '-5000px'; // hide main nav
		ht.style.left = '-5000px';

		switch (p) {
			case "none" :
				sn.style.display = 'block';
				break;
			case "block" :
				sn.style.display = 'none';
				break;
		}
	}

	function showHideNewsSub() {
		var sn = document.getElementById("newsSubnav");
		var nl = document.getElementById("navLinks");
		var ht = document.getElementById("headerTools");

		nl.style.left = '-5000px'; // hide main nav
		ht.style.left = '-5000px';

		switch (p) {
			case "none" :
				sn.style.display = 'block';
				break;
			case "block" :
				sn.style.display = 'none';
				break;
		}
	}

	$(window).resize(function() {
		var f = $(".footerCol1").css("float");
		var sn = document.getElementById("subnav");
		var si = document.getElementById("indexSlides");
		
		if (f=="left") { // desktop
			if (sn) {
				sn.style.display = 'block';
			}
			
			if (si) {
				if (timer==null) {
					fitSlides();
				}
			}
			
		} else { // phone
			
			if (si) {
				clearInterval(timer);
				fitSlides();
			}		
			
			if (sn) {
				sn.style.display = 'none';
			}
		}
	});