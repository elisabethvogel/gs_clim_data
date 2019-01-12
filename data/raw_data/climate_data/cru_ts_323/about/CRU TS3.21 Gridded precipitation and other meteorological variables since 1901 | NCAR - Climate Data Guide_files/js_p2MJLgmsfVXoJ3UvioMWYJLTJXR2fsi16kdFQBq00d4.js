/**
*  @file
*  This file contains miscellaneous script to enhance funtionality of the Atmos theme
* 
*/
(function ($) {
	
Drupal.behaviors.atmos_theme = function() {

  $(document).ready( function() {
    
    $("#newsletter").attr("value", "ENTER EMAIL ADDRESS");
  
    var text = "ENTER EMAIL ADDRESS";
  
    $("#mce-EMAIL").focus(function() {
      $(this).addClass("active");
      if($(this).attr("value") == text) $(this).attr("value", "");
    });
  
    $("#mce-EMAIL").blur(function() {
      $(this).removeClass("active");
      if($(this).attr("value") == "") $(this).attr("value", text);
    });
  });

};

}(jQuery));;
/**
 * @file
 * Attaches the imagecaption behavior to content.
 *
 * Script to create images with captions based on a CSS class placed on an image.
 * 
 * This script will search the web page's content after the document has been
 * loaded and look for <span>, <p> or <img> elements with a class name of either
 * img_caption_left, img_caption_right, or img_caption_clear_both.  If the script
 * matches elements with this attribute, it will rewrite the page's html
 * to style the image and caption text.  This script works with a properly
 * configured TinyMCE WYSIWYS editor, a properly configured Drupal site, and
 * requires jQuery. If you have any questions regarding TinyMCE or Drupal
 * configuration, email the author listed below.  This script is based on
 * Image Caption v1.3
 * 
 * @author      Alex Chaux <achaux@ucar.edu>
 * 
 * @see         http://www.arc90.com
 * @see         http://lab.arc90.com 
 * 
 * For debugging, use FireBux console.log, i.e.:
 * console.log($('div.mceTmpl').length);
 */

(function ($, Drupal, window, document, undefined) {

/**
 * imgcaption function that scans the document and rewrites HTML
 */
function atmos_imgcaption() {
	check_imgcaption_wrapper = true;
	check_old_imgcache = true;
	w_imgcache = false;
	
  // We have integrated TinyMCE templates.  We now have to check to see if there
  // is a div.mceTmpl template, and whether that div contains a child with the
  // atmos_imgcaption class or the ucar_imgcaption class (for backwards compatability).
	// If so, we need to resize the encapsulating div to the image size to avoid caption creep.
  $('div.mceTmpl').each(function(intIndex) {
		if($("div.ucar_imgcaption", this).length > 0 || $("div.atmos_imgcaption", this).length > 0){
			
			if($("div.atmos_imgcaption", this).length > 0){
				mceTmpl_div = $(this).find('div.atmos_imgcaption');
			}
			else if($("div.ucar_imgcaption", this).length > 0){
				mceTmpl_div = $(this).find('div.ucar_imgcaption');
			}
			if(mceTmpl_div.length > 0){
				try {
			
	// We have found div.mceTmpl with at least one child div.atmos_imgcaption
	// Find the first image and get its width
					
					mceTmpl_img = mceTmpl_div.find('img:first');
					try {
						if(mceTmpl_img_element = mceTmpl_img.get(0)){
							w_imgcache = mceTmpl_img_element.width;
							mceTmpl_div.width(w_imgcache);
						}
						else {
							try {
								mceTmpl_div_2 = $(this).children('div.atmos_imgcaption_wrapper');
								mceTmpl_div_3 = $(mceTmpl_div_2).children('div.atmos_imgcaption');
								mceTmpl_img_3 = mceTmpl_div_3.find('img:first');
								mceTmpl_img_element_3 = mceTmpl_img_3.get(0);
								if(mceTmpl_img_3.get(0) == '[object HTMLImageElement]'){
									w_imgcache = mceTmpl_img_element_3.width;
									mceTmpl_div_3.width(w_imgcache);
								}
							}
							catch(err2){
								$('body').append('<div class="message">58: '+err2.toString()+"</div>\n");
							}
						}
					}
					catch(err1){
						$('body').append('<div class="message">63: '+err1.toString()+"</div>\n");
					}
					check_old_imgcache = false;
				}
				catch(err) {
					$('body').append('<div class="message">68: '+err.toString()+"</div>\n");
				}
			}
		}
	});
	
	// Now we do the old process of rewriting portions of the page with javascript.
	// This code needs to remain for legacy reasons.
	if(check_old_imgcache == true){
		
  // Cycle through all DOM elements and capture elements with class name "img_caption_*"
    $('img, span').each(function(intIndex) {
      if ($(this).hasClass('img_caption_left') || $(this).hasClass('img_caption_right') || $(this).hasClass('img_caption_clear_both')) {
		  
  // Variable declaration block
        new_img = false;
        p_a = false;
        p_a_href = false;
        p_a_class = false;
        p_a_title = false;
        p_caption = false;
        p_img = false;
        p_parent = false;
        p_span = false;
        style_float = false;
        w_imgcache = false;
  
        p_id = 'atmos_imgcaption_p_' + intIndex;
        p_a_id = 'atmos_imgcaption_a_' + intIndex;
        style_float = 'floatl';
				
  // Get the class name to determin whether to float the img left or right
        if ($(this).hasClass('img_caption_right')) {
          style_float = 'floatr';
        }
        else if ($(this).hasClass('img_caption_clear_both')) {
          style_float = 'clearboth';
        }

  // Tags with img_caption_x class name can come in two elements, span or img.
  // Need to standardize formatting by capturing the caption text and then 
  // rebuilding the elements in the proper order.

  // Get the `p` parent for this element.  Get the image and clone it.
        p_parent = $(this).parents('p');

  // Check to see if the image is linked.  We are only interested in the first anchor/image
  // If found, store all the link information
        if(p_parent.find("a:first > img")){
          p_a = p_parent.find("a:first");
          p_a_href = p_a.attr('href');
          p_a_class = p_a.attr('class');
          p_a_title = p_a.attr('title');
        }
        
        try {
  // Store information for the first image.  It is possible to have an image in the caption!
  // Store all the image information
  				p_img = p_parent.find('img:first');
 					if(p_img.length > 0){
						p_img_element = p_img.get(0);
						w_imgcache = p_img_element.width;
						new_img = p_img.clone();
						new_img.attr('class', 'clear-block');
				
	// Check to see if there is a span around the image.  We are only interested in the first span/image
	// If found, remove it
						p_span = p_parent.find('span:first');
				
	// If this first span has an image, remove the span (including image)
						if(p_span.children('img')){
							if(p_span.length != 0){
								p_span.remove();
							} 
						}
				
	// Remove the original image
						p_img.remove();
				
	// Capture the caption text/html
						p_caption = p_parent.html();
				
	// Clear the parent p element and add some attributes
						p_parent.html('');
						p_parent.attr('id', p_id);
						p_parent.addClass('atmos_imgcaption ' + style_float);
						p_parent.width(w_imgcache);
	
	// If the original image was linked, replace the anchor tag
	// to the p element and append the cloned image
						if(p_a_href){
							p_parent.html('<a id="' + p_a_id + '"></a>');
							p_a = p_parent.find('#' + p_a_id);
							p_a.attr('href', p_a_href);
							p_a.attr('class', p_a_class);
							p_a.attr('title', p_a_title);
							p_a.append(new_img);
						}
						else {
					
	// else just append the cloned image
							p_parent.append(new_img);
						}
					
	// Append the caption text/html
						if(p_caption && p_caption.length > 0){
							p_parent.append('<div id="caption_div'+ intIndex +'" class="atmos_imgcaptionTXT">' + p_caption + '</div>');
						}
					
	// If we are clearing both sides of the image, need to create a wrapper element and then
	// center its content
						if(style_float == 'clearboth'){
							p_parent.before('<div id="atmos_imcaption'+ intIndex +'wrapper" class="atmos_imgcaption_wrapper" align="center"></div>');
							p_parent.remove();
							$('#atmos_imcaption'+ intIndex +'wrapper').append(p_parent);
						}
          }
        }
        catch(err) {
          $('body').append('<div class="message">184 '+err.toString()+"</div>\n");
        }
      }
    }); // end Cycle through all DOM elements
	} // end check_old_imgcache
} // end atmos_imgcaption

/**
 * Onload function that executes the imgcaption function after the web page has
 * finished loading in the web browser.
 */
$(document).ready(function(){
	atmos_imgcaption();
});

})(jQuery, Drupal, this, this.document);

;
