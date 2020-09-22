/**
 * @namespace WORKAREA.kitVariantOptions
 */
WORKAREA.registerModule('kitVariantOptions', (function () {
    'use strict';

    var toggleSelectAll = function(event) {
            var $selectAll = $(event.target),
                $optionSets = $selectAll.closest('[data-kit-variant-option-set]'),
                $checkboxes = $optionSets.find('[data-kit-variant-option]'),
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
            var $product = $(event.target).closest('[data-kit-variant-options-product]'),
                data = $product.data('kitVariantOptionsProduct'),
                $checkboxes = $product.find('[data-kit-variant-option]'),
                $counter;

            $product.data('selectedCount', $checkboxes.filter(':checked').length);

            if ( ! _.isEmpty(data.counter)) {
                $counter = $product.find(data.counter);
                $counter.text(
                    I18n.t(
                        'workarea.admin.kit_variant_options.selected',
                        { count: $product.data('selectedCount') }
                    )
                );
            }
        },

        updatePreviewMessage = function($form) {
            var $products = $('[data-kit-variant-options-product]', $form),
                $previewSection = $('[data-kit-variant-options-preview]', $form),
                anySelected = _.some($products, function(table) {
                    return $(table).data('selectedCount') > 0;
                });


            if (anySelected) {
                $.post(
                    $previewSection.data('kitVariantOptionsPreview'),
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
                '[data-kit-variant-option-select-all]',
                toggleSelectAll
            );
        },

        setupCounter = function($form) {
            $form.on(
                'click',
                '[data-kit-variant-option]',
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
         * @memberof WORKAREA.kitVariantOptions
         */
        init = function ($scope) {
            var $form = $('[data-kit-variant-options]', $scope);

            if (_.isEmpty($form)) { return; }

            setupSelectAll($form);
            setupCounter($form);
            setupPreviewMessage($form);
        };

    return {
        init: init
    };
}()));
