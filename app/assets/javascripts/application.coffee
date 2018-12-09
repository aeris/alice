#= require rails-ujs
#= require jquery
#= require jstree

$ ->
	$.jstree.defaults.core.themes.variant = "large";
	$('.tree').jstree()
