(function ($) {

Drupal.behaviors.lulzbotProducts = {
  attach : function (context, settings) {
    $("body").once("lulzbot-products", function () {
      if ($(".product-image").length > 0) {
	    $(".main-product-image a").colorbox();
		var main_a = $(".main-product-image a");
		var main_img = $(".main-product-image a img");
		// Make sure main-product image has a representative in the list
		$(".more-product-images").prepend($('<a href="'+main_a.attr("href")+'"><img src="'+main_img.attr("src").replace("uc_product", "uc_thumbnail")+'" alt="" title="" /></a>'));
	    $(".more-product-images a").click(function () {
	      var href = $(this).attr("href");
		  var src = $("img", $(this)).attr("src").replace("uc_thumbnail", "uc_product");
		  var main_href = $(".main-product-image a").attr("href");
		  var main_src = $(".main-product-image a img").attr("src").replace("uc_product", "uc_thumbnail");
		
		  //$(this).attr("href", main_href);
		  //$("img", $(this)).attr("src", main_src)
		  $(".main-product-image a").attr("href", href);
		  $(".main-product-image a img").attr("src", src)
		  return false;
	    });
		if ($(".more-product-images a").length > 0) {
		  $(".more-product-images a").wrap("<li />");
		  $(".more-product-images").wrapInner($("<ul />"));
		  $(".more-product-images ul").jcarousel();
		}
	  }
	  /*var selected = $.cookie("selected") ? $("#product-tabs > .item-list li").eq($.cookie("selected")).find("a") : $("#product-tabs > .item-list li.first a");
	  Drupal.lulzbotShowTab(selected);
	  $("#product-tabs > .item-list li a").click(function () {
	    Drupal.lulzbotShowTab($(this));
		return false;
	  })
	  $(".add-new-comment").click(function () {
	    if ($("#edit-comment-form").hasClass("collapsed")) {
		  $(".fieldset-title", $("#edit-comment-form")).click();
		}
	  });*/
	});
  }
};

Drupal.lulzbotShowTab = function (el) {
  if (el.length == 0) {
    return;
  }
  $("#product-tabs .tab-container").hide();
  $("#product-tabs > .item-list li a").removeClass("active-tab");
  var href = el.attr("href").split("#");
  var id = href[1];
  $.cookie("selected", el.parent().index());
  el.addClass("active-tab");
  $("#" + id).show();
}

})(jQuery);