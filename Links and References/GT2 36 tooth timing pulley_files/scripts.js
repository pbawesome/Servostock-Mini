(function ($) {

$.fn.cycle.transitions.scrollBothWays = function($cont, $slides, opts) {
	$cont.css('overflow','hidden');
	opts.before.push($.fn.cycle.commonReset);
	// custom transition fn (trying to get it to scroll forward and backward)
	opts.fxFn = function(curr, next, opts, cb, fwd) {

		var w = $cont.width();
		opts.cssFirst = { left: 0 };
		opts.animIn	  = { left: 0 };
		if(fwd){
			opts.cssBefore= { left: w, top: 0 };
			opts.animOut  = { left: 0-w };
		}else{
			opts.cssBefore= { left: -w, top: 0 };
			opts.animOut  = { left: w };
		};
		var $l = $(curr), $n = $(next);
		var speedIn = opts.speedIn, speedOut = opts.speedOut, easeIn = opts.easeIn, easeOut = opts.easeOut, animOut = opts.animOut, animIn = opts.animIn;
		$n.css(opts.cssBefore);
		var fn = function() {$n.show();$n.animate(animIn, speedIn, easeIn, cb);};
		$l.animate(animOut, speedOut, easeOut, function() {
			if (opts.cssAfter) $l.css(opts.cssAfter);
			if (!opts.sync) fn();
		});
		if (opts.sync) fn();
	};
};

Drupal.behaviors.lubrizol = {
  attach: function (context, settings) {
    $("body").once("lubrizol", function () { 
	  // We want HTML in the newsletter box
	  if ($(".block-simplenews .content").length > 0) {
	    $(".block-simplenews .content").html($(".block-simplenews .content").html().replace(/&lt;/g, "<").replace(/&gt;/g, ">"));
	  }
	   if ($(".view-blog .field-type-image .field-items > div").length > 1) {
	    $(".view-blog .field-type-image .field-items")
		.cycle({
			fx: "scrollLeft", 
			timeout : 5000,
		});
	  }
	  if ($("#slideshow .content li").length > 0) {
	    $("#slideshow .content ul")
		.before('<a class="slide-prev"></a>')
		.before('<a class="slide-next"></a>')
		.after('<div class="slide-nav"></div>')
		.cycle({
			fx: "scrollHorz", 
			timeout : 5000,
			pager: ".slide-nav",
			prev: ".slide-prev",
			next: ".slide-next",
			easeIn:   'easeOutBack',
			easeOut:  'easeOutBack'
		});
	  }
	  if ($("#featured").length > 0) {
	    $("#featured h2").each(function () {
	      var text = $(this).text().replace(/ /, ' <span>');
		  if (text.search("<span>") == -1) {
		    text += '</span>';
		  }
          $(this).html(text);
		});
      }	  
	  var search = "Search...";
	  var searchInput = $("#block-search-form .form-text");
	  if (searchInput.val() == '') {
	    searchInput.val(search);
	  }
	  searchInput.focus(function () {
	    if ($(this).val() == search) {
		  $(this).val('');
		}
	  });
	  searchInput.blur(function () {
	    if (!$(this).val()) {
		  $(this).val(search);
		}
	  });
	  // Adjust the size of rows
	  var selectors = [".catalog-list"];
	  for (i in selectors) {
	    Drupal.lulzbotAdjustRows(selectors[i]);
	  }
    }); 
	
	if ($("#block-uc-catalog-catalog").length > 0) {
	  $("#block-uc-catalog-catalog h2").html($("#block-uc-catalog-catalog h2").text().replace("Category", '<span>Category</span>'));
	}
	
	$("#block-uc-cart-cart").click(function () {
	  window.location = "/cart";
	});
  }
}

Drupal.lulzbotAdjustRows = function (selector, check_images) {
  var selector_length = $(selector).length > 0;
  // Make sure images are loaded
  if (selector_length && !check_images) {
    // See if there's at least one image in the list
	if ($(selector).find('img').length > 0) {
	  // Wait for at least one of these images to load
	  var img = new Image();
	  img.src = $(selector).find('img').eq(0).attr("src");
	  img.onload = function () {
	    Drupal.lulzbotAdjustRows(selector, true);
	  }
	}
	else {
	  Drupal.lulzbotAdjustRows(selector, true);
	}
  }
  // Adjust the height of catalog items
  else if (selector_length) {
    // Adjust the title height so that view details button line up with each other
    var maxHeight = 0;
	var tester = $('<div style="width:1px;height:1px;clear:both;"></div>');
	var lastTop = -1;
	var rowEnd = 0;
    $(selector + " li").each(function () {
	  var title = $(".views-field-title", $(this));
	  title.append(tester);
	  var top = title.offset().top;
	  var height = tester.offset().top - top;
	  if (maxHeight < height) {
	    maxHeight = height;
	  }
	  if (((top != lastTop && lastTop > -1 && $(this).index() > 0) || ($(this).index() == $(selector + " li").length - 1)) && maxHeight > 0) {
	    var index = $(this).index() == $(selector + " li").length - 1 ? $(this).index() : $(this).index() - 1;
	    for (i=rowEnd; i<=index; i++) {
		  $(selector + " li").eq(i).find(".views-field-title").css("height", maxHeight);
		}
		rowEnd = $(this).index();
		maxHeight = height;
	  }
	  lastTop = top;
	});		
	// Now make sure the height of the list items is correct		
    maxHeight = 0;
	lastTop = -1;
	rowEnd = 0;
    $(selector + " li").each(function () {
	  $(this).append(tester);
	  var top = $(this).offset().top;
	  var height = tester.offset().top - top;
	  if (maxHeight < height) {
	    maxHeight = height;
	  }
	  if (((top != lastTop && lastTop > -1 && $(this).index() > 0) || ($(this).index() == $(selector + " li").length - 1)) && maxHeight > 0) {
	    var index = $(this).index() == $(selector + " li").length - 1 ? $(this).index() : $(this).index() - 1;
	    console.log("max", maxHeight);
	    for (i=rowEnd; i<=index; i++) {
		  $(selector + " li").eq(i).css("height", maxHeight);
		}
		rowEnd = $(this).index();
		maxHeight = height;
	  }
	  lastTop = top;
	});		
	tester.remove();
  }
}

$(document).ready(function() { 
	var host = window.location.host
	$("a").each(function() {
		var href = $(this).attr("href")
		if (href.indexOf("http") > -1 && href.length > 1 && href.indexOf(host) == -1) {
			$(this).attr("target", "_blank")
		}
	})
	$("#block-search-form .form-submit").attr("value","GO");
	$("#cta .block, #featured .featured").hover(
		function() {
			$(this).find(".hover").stop().animate({
				"filter": "alpha(opacity=100)", 
				"-ms-filter": "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)",
				"opacity": "1"
			}, 300)
		}, 
		function() {
			$(this).find(".hover").stop().animate({
				"filter": "alpha(opacity=0)", 
				"-ms-filter": "progid:DXImageTransform.Microsoft.Alpha(Opacity=0)",
				"opacity": "0"
			}, 300)
		}
	)
	
	$(".page-node .field-item img").colorbox({html: function() {
		var url = $(this).attr("src")
		return '<img src="'+url+'" alt="" />'
	}})
	function css_browser_selector(u){var ua=u.toLowerCase(),is=function(t){return ua.indexOf(t)>-1},g='gecko',w='webkit',s='safari',o='opera',m='mobile',h=document.documentElement,b=[(!(/opera|webtv/i.test(ua))&&/msie\s(\d)/.test(ua))?('ie ie'+RegExp.$1):is('firefox/2')?g+' ff2':is('firefox/3.5')?g+' ff3 ff3_5':is('firefox/3.6')?g+' ff3 ff3_6':is('firefox/3')?g+' ff3':is('gecko/')?g:is('opera')?o+(/version\/(\d+)/.test(ua)?' '+o+RegExp.$1:(/opera(\s|\/)(\d+)/.test(ua)?' '+o+RegExp.$2:'')):is('konqueror')?'konqueror':is('blackberry')?m+' blackberry':is('android')?m+' android':is('chrome')?w+' chrome':is('iron')?w+' iron':is('applewebkit/')?w+' '+s+(/version\/(\d+)/.test(ua)?' '+s+RegExp.$1:''):is('mozilla/')?g:'',is('j2me')?m+' j2me':is('iphone')?m+' iphone':is('ipod')?m+' ipod':is('ipad')?m+' ipad':is('mac')?'mac':is('darwin')?'mac':is('webtv')?'webtv':is('win')?'win'+(is('windows nt 6.0')?' vista':''):is('freebsd')?'freebsd':(is('x11')||is('linux'))?'linux':'','js']; c = b.join(' '); h.className += ' '+c; return c;}; css_browser_selector(navigator.userAgent);
})

})(jQuery);