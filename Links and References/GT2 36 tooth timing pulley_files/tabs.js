(function ($) {

Drupal.behaviors.lulzbotProductTabs = {
  attach : function (context, settings) {
    $("body").once("lulzbot-product-tabs", function () {
	  var selected = $.cookie("selected") ? $("#product-tabs > .item-list li").eq($.cookie("selected")).find("a") : $("#product-tabs > .item-list li.first a");
	  Drupal.lulzbotShowTab(selected);
	  $("#product-tabs > .item-list li a").click(function (e) {
	    Drupal.lulzbotShowTab($(this));
		e.preventDefault();
		return false;
	  });
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
};

})(jQuery);