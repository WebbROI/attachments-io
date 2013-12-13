//= require jquery_ujs
//= require retina_tag
//= require jquery.livequery.min.js
//= require ng-infinite-scroll.js
//= require twitter/bootstrap/alert
//= require twitter/bootstrap/dropdown
//= require twitter/bootstrap/collapse

// FIXME: Max, please fix this ;)
// fix dropdown
$('.dropdown').dropdown();

$(document).ready(function() {
    $('.toggle-debug-code').click(function() {
        $(this).next('.debug-code').slideToggle();
    });
});

