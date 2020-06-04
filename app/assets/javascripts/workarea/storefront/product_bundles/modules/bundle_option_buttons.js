/**
 * @namespace WORKAREA.bundleOptionButtons
 */
WORKAREA.registerModule('bundleOptionButtons', (function () {
    'use strict';

    var replaceProductDetails = function (event) {
            var $link = $(event.delegateTarget),
                newUrl = $link.attr('href');

            event.preventDefault();

            $.get(newUrl, function (html) {
                var $newDetails = $(html)
                                    .find('.bundled-product-details')
                                        .addBack('.bundled-product-details');

                $link.closest('.bundled-product-details').replaceWith($newDetails);

                WORKAREA.initModules($newDetails);
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.bundleOptionButtons
         */
        init = function ($scope) {
            $('[data-bundle-option-button]', $scope).on('click', replaceProductDetails);
        };

    return {
        init: init
    };
}()));
