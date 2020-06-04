/**
 * @namespace WORKAREA.bundleSkuSelects
 */
WORKAREA.registerModule('bundleSkuSelects', (function () {
    'use strict';

    var replaceProductDetails = function ($container, optionParams, newDetails) {
            var $newDetails = $(newDetails)
                                  .find('.bundled-product-details')
                                      .addBack('.bundled-product-details');

            $container.replaceWith($newDetails);
            WORKAREA.initModules($newDetails);
        },

        disableAddToCart = function ($form) {
            $form.find(':input').attr('disabled', 'disabled');
        },

        enableAddToCart = function ($form) {
            $form.find(':input').removeAttr('disabled');
        },

        getDetailParams = function($form) {
            return $form.find(':input')
                        .not(':hidden')
                        .add('input[name="bundled_items[][via]"]', $form)
                        .add('input[name="via"]', $form)
                        .add('input[name="bundled_items[][bundle_id]"]', $form)
                        .add('input[name="bundle_id"]', $form)
                        .serialize();
        },

        handleSkuSelection = function (event) {
            var $select = $(event.currentTarget),
                $productDetailContainer = $select.closest('.bundled-product-details'),
                $form = $select.closest('form'),
                slug = $select.data('bundleSkuSelect'),
                endpoint = WORKAREA.routes.storefront.bundleDetailsProductPath(slug),
                detailParams = getDetailParams($productDetailContainer),
                promise;

            event.preventDefault();
            disableAddToCart($form);

            promise = $.get(endpoint, detailParams).done(function (html) {
                replaceProductDetails(
                    $productDetailContainer,
                    detailParams,
                    html
                );

                enableAddToCart($form);
            });

            WORKAREA.loading.createLoadingDialog(promise);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.bundleSkuSelects
         */
        init = function ($scope) {
            $('[data-bundle-sku-select]', $scope)
            .on('change', handleSkuSelection);
        };

    return {
        init: init
    };
}()));
