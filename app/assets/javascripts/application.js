// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets//sprockets-directives) for details
// about supported directives.
//
//= require vendor/jquery
//= require jquery_ujs
//= require vendor/semantic
//= require retina_tag

//
// Initialize components
//

$(document).ready(function() {

    $('.ui.dropdown')
        .dropdown()
    ;

    $('.ui.checkbox')
        .checkbox()
    ;

    var source = new EventSource('/streaming/events');

    source.addEventListener('message', function(event) {
        console.log(event.data);
    });

    source.addEventListener('progressbar', function(event) {
        var data = JSON.parse(event.data);

        if ( ! $('#synchronization-'+data.id).length)
            return;

        switch (data.action)
        {
            case 'update':
                var percent = (data.parsed / data.count * 100);

                $('.progress .bar').css('width', percent+'%');
                $('#progress-percentage').html(Math.round(percent)+'%');
                $('#progress-title').html('Emails parsed '+data.parsed+' of '+data.count);

                break;
        }
    });

    source.addEventListener('synchronization_add_file', function(event) {
        var data = JSON.parse(event.data);

        if ( ! $('#synchronization-'+data.id).length)
            return;

        var table = $('#synchronized-files');

        if (table.is(':hidden'))
        {
            table.slideDown();
        }

        table.find('tbody').prepend(
            '<tr>' +
                '<td><a href="'+data.file.link+'" target="_blank">'+data.file.name+'</a></td>' +
                '<td>'+data.file.size+'</td>' +
            '</tr>'
        );
    });

    source.addEventListener('synchronization_update', function(event) {
        var data = JSON.parse(event.data);

        if ( ! $('#synchronization-'+data.id).length)
            return;

        switch (data.action)
        {
            case 'reload_page':
                window.location.reload();
                break;
        }
    });

});