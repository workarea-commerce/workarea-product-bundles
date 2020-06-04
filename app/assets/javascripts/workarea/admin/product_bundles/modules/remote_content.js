/**
 * @namespace WORKAREA.remoteContent
 */
WORKAREA.registerModule('remoteContent', (function () {
    'use strict';

    var loadContent = function(data, html) {
            var newContent = $(html);

            if (data.replace) {
                $(data.replace).replaceWith(newContent);
            } else if (data.insert_after) {
                newContent.insertAfter($(data.insert_after));
            } else if (data.container) {
                $(data.container).html(newContent);
            }

            WORKAREA.initModules(newContent);
        },

        setupListener = function($link) {
            var data = $link.data('remoteContent');

            $link.on('click', function(event) {
                event.preventDefault();

                $.get($link.attr('href'))
                    .done(_.partial(loadContent, data));
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.remoteContent
         */
        init = function ($scope) {
            var $links = $('[data-remote-content]', $scope);

            if (_.isEmpty($links)) { return ; }

            _.each($links, function(link) {
                setupListener($(link));
            });
        };

    return {
        init: init
    };
}()));
