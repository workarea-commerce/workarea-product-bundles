/**
 * @namespace WORKAREA.familyProductAddToCart
 */
WORKAREA.registerModule('familyProductAddToCart', (function () {
    'use strict';

    var sendRequest = function($form, $products) {
            var payload = {
                'product_id': $form.find('[name="product_id"]').val()
            };

            payload.items = _.map($products, function(product) {
                var $productForm = $(product).find('form');

                return _.reduce($productForm.find(':input'), function(inputs, input){
                    var $input = $(input),
                        name = $input.attr('name');

                    if (name !== 'authenticity_token' && name !== 'utf8') {
                        inputs[name] = $input.val();
                    }

                    return inputs;
                }, {});
            });

            return $.post($form.attr('action'), payload);
        },

        addItemsToCart = function($form, event) {
            var promise = null,
                options = $form.data('dialog'),
                $selectedProducts = $('[id^="family_product_"]:checked').next('[data-packaged-product-id]'),
                isValid = _.reduce($selectedProducts, function(valid, product) {
                    var $product = $(product),
                        result =  $product.find('form').valid();

                    return valid ? result : valid;
                }, true);

            event.preventDefault();

            if (isValid && !_.isEmpty($selectedProducts)) {
                promise = sendRequest($form, $selectedProducts);
                WORKAREA.dialog.createFromPromise(promise, options.dialogOptions);
            }
        },

        initFamilyProducts = function($products) {
            $products.each(function(index, product) {
                var $product = $(product),
                    productId = $product.data('packagedProductId'),
                    checkboxTemplate = JST['workarea/storefront/package_products/templates/family_add_to_cart_checkbox'];

                $(checkboxTemplate({ id: productId })).insertBefore($product);
            });
        },

        bindAddToCart = function($form) {
            $form.on('submit', _.partial(addItemsToCart, $form));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.familyProductAddToCart
         */
        init = function ($scope) {
            var $addToCartForm = $('.product-details--family .product-details__add-to-cart-form', $scope),
                $products = $('[data-packaged-product-id]', $scope);

            if (_.isEmpty($addToCartForm) || _.isEmpty($products)) {
                return;
            }

            initFamilyProducts($products);
            bindAddToCart($addToCartForm);
        };

    return {
        init: init
    };
}()));
