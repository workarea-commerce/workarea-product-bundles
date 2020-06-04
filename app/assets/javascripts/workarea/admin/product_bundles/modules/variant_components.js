/**
 * @namespace WORKAREA.variantComponents
 */
WORKAREA.registerModule('variantComponents', (function () {
    'use strict';

    var toggleSelectAll = function(event) {
            var $selectAll = $(event.target),
                $product = $selectAll.closest('[data-variant-component-product]'),
                $checkboxes = $product.find('[data-variant-component-sku]'),
                isChecked = $selectAll.is(':checked');

            _.each($checkboxes, function(checkbox) {
                var $checkbox = $(checkbox);

                if ( ! $checkbox.is(':hidden')) {
                    $checkbox.prop('checked', isChecked);
                }
            });

            updateCount(event);
        },

        updateCount = function(event) {
            var $product = $(event.target).closest('[data-variant-component-product]'),
                data = $product.data('variantComponentProduct'),
                $checkboxes = $product.find('[data-variant-component-sku]'),
                $counter;

            $product.data('selectedCount', $checkboxes.filter(':checked').length);

            if ( ! _.isEmpty(data.counter)) {
                $counter = $product.find(data.counter);
                $counter.text(
                    I18n.t(
                        'workarea.variant_components.selected',
                        { count: $product.data('selectedCount') }
                    )
                );
            }
        },

        updatePreviewMessage = function($form) {
            var $products = $('[data-variant-component-product]', $form),
                $previewSection = $('[data-component-sku-selection-preview]', $form),
                anySelected = _.some($products, function(table) {
                    return $(table).data('selectedCount') > 0;
                });


            if (anySelected) {
                $.post(
                    $previewSection.data('componentSkuSelectionPreview'),
                    $form.serialize()
                ).done(function(html) {
                    $previewSection.html(html);
                });
            } else {
                $previewSection.html('');
            }
        },

        setupSelectAll = function($form) {
            $form.on(
                'click',
                '[data-variant-component-select-all]',
                toggleSelectAll
            );
        },

        setupCounter = function($form) {
            $form.on(
                'click',
                '[data-variant-component-sku]',
                updateCount
            );
        },

        setupPreviewMessage = function($form) {
            $form.on(
                'change',
                'input, select',
                _.partial(updatePreviewMessage, $form)
            );
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.variantComponents
         */
        init = function ($scope) {
            var $form = $('[data-variant-components]', $scope);

            if (_.isEmpty($form)) { return; }

            setupSelectAll($form);
            setupCounter($form);
            setupPreviewMessage($form);
        };

    return {
        init: init
    };
}()));
