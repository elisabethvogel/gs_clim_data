
if (!hideFooter) { // Must before before page load, I.E. outside of (document).ready
  document.write('<div id="orgFooter"></div>');
}

if (hideNSF == 'undefined') { var hideNSF = false; }
if (contactLink == 'undefined') { var contactLink = "mailto:webmaster@ucar.edu"; }
if (hideOrgNav == 'undefined') { var hideOrgNav = false; }
if (hideFooter == 'undefined') { var hideFooter = false; }
if (footerColor == 'undefined') { var footerColor = "#ccc"; }

jQuery(document).ready(function(){

/* OrgFooter Start */
  if (!hideFooter) { 
    
    var orgFooterStyle = '<style>' +
      '#orgFooter { clear: both; padding-bottom: 20px; color: ' + footerColor + '; font-size: 12px; font-family: arial, helvetica, sans-serif; }' + 
      '#orgFooter a { color: ' + footerColor + '; text-decoration: none; }' + 
      '#orgFooter a:hover { color: ' + footerColor + '; text-decoration: underline; }' + 
      '</style>'; 
  
    var d = new Date();
    var year = d.getFullYear();
  
    var ncarHTML = '' + 
      '<p>&copy; ' + year + ' UCAR | ' + 
      '<a href="http://www2.ucar.edu/privacy-policy" target="_blank">Privacy Policy</a> | ' + 
      '<a href="http://www2.ucar.edu/terms-of-use" target="_blank">Terms of Use</a> | ' + 
      '<a href="https://www2.ucar.edu/notification-copyright-infringement-digital-millennium-copyright-act" target="_blank">Copyright Issues</a> | ' + 
      '<a href="http://www.nsf.gov" target="_blank">Sponsored by NSF</a> | ' + 
      '<a href="http://www.ucar.edu" target="_blank">Managed by UCAR</a> | ' + 
      '<a href="' + contactLink + '">Webmaster/Feedback</a> ' + 
      '<br>Postal Address: P.O. Box 3000, Boulder, CO 80307-3000 &bull; ' +  
      'Shipping Address: 3090 Center Green Drive, Boulder, CO 80301</p>'; 
  
    var nsfStatement = '<p>The National Center for Atmospheric Research is sponsored by the National Science Foundation. ' + 
      'Any opinions, findings and conclusions or recommendations expressed in this publication are those ' + 
      'of the author(s) and do not necessarily reflect the views of the National Science Foundation.</p>';
  
    jQuery('head').append(orgFooterStyle);
  
    jQuery('#orgFooter').append(ncarHTML);
    
    if (!hideNSF) { 
      jQuery('#orgFooter').append(nsfStatement);
    }
  }
/* OrgFooter End */
  
  
  
/* OrgNav Start */
  if (!hideOrgNav) {
    var timeout = 3000; //milliseconds - how long the menu is 'active' after mouseout
    var timer = 1000; // load time
    var load = true;  
    var loadtimer;
    var cleartimer;

var orgHtml = '<div id="orgNavV1">' + 
'<div id="loaderOrg"><img src="' + jsHost + 'www.ncar.ucar.edu/js/orgnav/loaderOrg.gif"></div>' + 
'<div id="ucarOrg"><ul><li><a href="http://www2.ucar.edu" title="">UCAR</a><ul><li><a href="http://www2.ucar.edu" title="">University Corporation for Atmospheric Research</a></li> <li><a href="http://www.ucp.ucar.edu" title="">UCAR Community Programs</a><ul><li><a href="http://www.comet.ucar.edu" title="The COMET Program">COMET</a></li> <li><a href="http://www.cosmic.ucar.edu" title="Constellation Observing System for Meteorology, Ionosphere &amp; Climate">COSMIC</a></li> <li><a href="http://dls.ucar.edu/" title="Digital Learning Sciences">DLS</a></li> <li><a href="https://www.ucp.ucar.edu/globe" title="Global Learning &amp; Observations to Benefit the Environment">GLOBE</a></li> <li><a href="http://joss.ucar.edu/" title="Joint Office for Science Support">JOSS</a></li> <li><a href="http://www.meted.ucar.edu" title="COMET&#039;s Meteorology Education &amp; Training">MetEd</a></li> <li><a href="http://scied.ucar.edu" title="">UCAR Center for Science Education</a></li> <li><a href="http://ucarconnect.ucar.edu" title="">UCARConnect</a></li> <li><a href="http://www.unidata.ucar.edu" title="Unidata Program Center">Unidata</a></li> <li><a href="http://www.vsp.ucar.edu" title="Visiting Scientist Programs">VSP</a></li> <li><a href="http://www.ucp.ucar.edu/directors-office" title="">UCP Director&#039;s Office</a></li> <li><a href="http://www.ucp.ucar.edu/budget/budget-and-administration-office" title="">UCP Budget &amp; Administration</a></li> </ul></li> <li><a href="http://president.ucar.edu" title="">President&#039;s Office</a><ul><li><a href="http://www2.ucar.edu/atmosnews/communications" title="">Communications &amp; Media Relations</a></li> <li><a href="http://president.ucar.edu/development" title="">Development &amp; Partnerships</a></li> <li><a href="http://president.ucar.edu/government-relations" title="">Government Relations</a></li> <li><a href="http://president.ucar.edu/governance" title="">Membership</a></li> <li><a href="http://president.ucar.edu/counsel" title="">Office of General Counsel</a></li> <li><a href="http://president.ucar.edu/university-relations" title="">University Relations</a></li> </ul></li> <li><a href="https://www2.fin.ucar.edu/hr" title="">Human Resources</a></li> <li><a href="http://www2.fin.ucar.edu" title="">Finance &amp; Administration</a></li> </ul></li> </ul></div>' + 
'<div id="ncarOrg"><ul><li><a href="http://ncar.ucar.edu/" title="">NCAR</a><ul><li><a href="http://ncar.ucar.edu/" title="">National Center for Atmospheric Research</a></li> <li><a href="http://www2.acom.ucar.edu" title="">Atmospheric Chemistry Observations &amp; Modeling Lab</a></li> <li><a href="http://www2.cgd.ucar.edu" title="">Climate and Global Dynamics Lab</a></li> <li><a href="http://www.cisl.ucar.edu/" title="">Computational &amp; Information Systems Lab</a></li> <li><a href="http://www.eol.ucar.edu/" title="">Earth Observing Lab</a></li> <li><a href="http://www2.hao.ucar.edu" title="">High Altitude Observatory</a></li> <li><a href="http://www.mmm.ucar.edu" title="">Mesoscale &amp; Microscale Meteorology Lab</a></li> <li><a href="http://www.ral.ucar.edu/" title="">Research Applications Lab</a></li> <li><a href="http://ncar.ucar.edu/directorate" title="">Director&#039;s Office</a></li> <li><a href="http://www.asp.ucar.edu/" title="">Advanced Study Program</a></li> <li><a href="http://ncar.ucar.edu/integrated-science" title="">Integrated Science Program</a></li> <li><a href="http://ncar.ucar.edu/budget-and-planning" title="">Budget &amp; Planning Office</a></li> <li><a href="http://library.ucar.edu" title="">NCAR Library</a></li> </ul></li> </ul></div>' + 
'<div id="peopleOrg"><ul><li><a href="http://staff.ucar.edu" title="">Find People</a><ul><li><a href="http://staff.ucar.edu" title="">Staff Directory</a></li> <li><a href="http://staff.ucar.edu/browse/visitors" title="">Scientific Visitors</a></li> </ul></li> </ul></div>' + 
'<div id="contactOrg"><ul><li><a href="http://www2.ucar.edu/contact-us" title="">Locations/Directions</a><ul><li><a href="http://www2.ucar.edu/contact-us" title="">Maps, Directions, Help</a></li> <li><a href="http://scied.ucar.edu/visit" title="">Public &amp; School Tours</a></li> </ul></li> </ul></div>' + 
'<div id="emergencyOrg"><ul><li><a href="http://www2.ucar.edu/emergency" title="">Closures/Emergencies</a></li> </ul></div>' + 
'</div>';


    var orgStyle = '<style>' + 
      '#orgNavV1 { padding: 0px; margin: 0px; text-align: left; position: absolute; top: 0px; left: 0px; z-index: 499; width: 100%; background: #333; color: #EED45E; height: 20px; line-height: 20px; font-family: arial, helvetiva, sans-serif; font-size: 11px;}' +  
      '#orgNavV1 #loaderOrg { padding: 0px 3px; margin: 0px; height: 20px; width: 20px; }' + 
      '#orgNavV1 #loaderOrg img { padding: 0px; margin: 0px; position: absolute; top: 5px; left: 5px; display: none; }' +  
      '#orgNavV1 div { padding: 0px; margin: 0px; position: relative; float: left; }' +  
      '#orgNavV1 div ul { padding: 0px 8px; margin: 0px; list-style: none;  cursor: pointer; }' +  
      '#orgNavV1 div ul li { background: none; line-height: 20px; padding: 0px; margin: 0px; font-family: arial, helvetiva, sans-serif; font-size: 11px; line-height: 20px; }' +  
      '#orgNavV1 div#peopleOrg ul li, #orgNavV1 div#contactOrg ul li { text-align: right; float: right; padding: 0px 8px; font-family: arial, helvetiva, sans-serif; font-size: 11px; line-height: 20px; }' + 
      '#orgNavV1 div#emergencyOrg, div#peopleOrg, div#contactOrg { float: right; width: auto; }' + 
      '#orgNavV1 div img { position: relative; bottom: 1px; left: 3px; }' +  
      '#orgNavV1 div ul ul { display: none; padding: 0px; margin: 0px; position: absolute; top: 20px; left: 0px; list-style: none; }' +  
      '#orgNavV1 div ul ul ul { display: block; position: relative; top: 0px; left: -8px;}' +  
      '#orgNavV1 div#peopleOrg ul ul { left: -84px; }' +  
      '#orgNavV1 div#contactOrg ul ul { left: -82px; }' +  
      '#orgNavV1 div:hover { background: #666; }' +  
      '#orgNavV1 div#loaderOrg:hover { background: none; }' +  
      '#orgNavV1 div ul ul li { padding: 0px 8px; width: 270px; background: #666; border-bottom: 1px solid #999; font-family: arial, helvetiva, sans-serif; font-size: 11px; line-height: 20px; }' + 
      '#orgNavV1 div ul ul ul li { padding: 0px 8px 0px 16px; width: 262px; background: #666; border-bottom: 0px solid #999; border-top: 1px solid #999; font-family: arial, helvetiva, sans-serif; font-size: 11px; line-height: 20px; }' + 
      '#orgNavV1 div#peopleOrg ul ul li, #orgNavV1 div#contactOrg ul ul li { width: 150px; padding: 0px 15px 0px 8px; font-family: arial, helvetiva, sans-serif; font-size: 11px; line-height: 20px; }' + 
      '#orgNavV1 div ul ul li a, #orgNavV1 div ul li a, #orgNavV1 div ul ul li a:hover, #orgNavV1 div ul li a:hover { display: block; width: 100%; padding: 0px; margin: 0px; text-decoration: none; color: #EED45E; background: none; font-family: arial, helvetiva, sans-serif; font-size: 11px; line-height: 20px; }' + 
      '#orgNavV1 div ul ul li a:hover { font-weight: bold; }' + 
      '#orgNavV1 div ul ul li.last { border: 0px; }' + 
      'body { padding-top: 20px; }' + 
      '</style>'; 
      
    var load = true;  
    var loadtimer;
    var cleartimer;
      
    jQuery('head').append(orgStyle);
    
    jQuery('body').prepend(orgHtml);

    jQuery('#ucarOrg, #ncarOrg, #peopleOrg, #contactOrg').hover(function() {
      var thisID = jQuery(this).attr('id');
      if (load) {
        jQuery('#orgNavV1 #loaderOrg img').show();
        loadtimer = setTimeout(function() {
          jQuery('#orgNavV1 #loaderOrg img').hide();
          load = false;
          jQuery('#' + thisID).find('ul li ul').show();
        }, timer);    
      } else {
        jQuery('#' + thisID).find('ul li ul').show();
      }
      clearTimeout(cleartimer);
    }, function() {
      var thisID = jQuery(this).attr('id');
      jQuery('#orgNavV1 #loaderOrg img').hide();
      if (!load) {
        cleartimer = setTimeout(function() {
          load = true;
        }, timeout);
      }
      clearTimeout(loadtimer);
      jQuery('#' + thisID).find('ul li ul').hide();    
    });
  }
/* OrgNav End */




});

