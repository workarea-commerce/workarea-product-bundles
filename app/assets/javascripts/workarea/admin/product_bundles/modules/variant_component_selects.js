/**
 * @namespace WORKAREA.variantComponentSelects
 */
WORKAREA.registerModule('variantComponentSelects', (function () {
    'use strict';

    var filterOptions = function($select, $skuSelect) {
            var selectValue = $select.val(),
                $options = $skuSelect.find('[data-variant-component-option]');

            if (_.isEmpty(selectValue)) {
                $skuSelect.addClass('hidden').val('');
                return;
            } else {
                $skuSelect.removeClass('hidden').val('');
            }

            _.each($options, function(option) {
                var $option = $(option),
                    optionValue = $option.data('variantComponentOption');

                if (optionValue !== selectValue) {
                    $option.remove();
                }
            });
        },

        resetSelect = function($select) {
            var initialSelectState = $select.data('originalState');
            $select.empty().append(initialSelectState);
        },

        saveInitialState = function($select) {
            $select.data('originalState', $select.prop('innerHTML'));
        },

        setupListener = function($select) {
            var $skuSelect = $select
                                .closest('tr')
                                .find('[data-variant-component-option]')
                                .closest('select');

            saveInitialState($skuSelect);

            $select.on('change', function(event) {
                resetSelect($skuSelect);
                filterOptions($select, $skuSelect);
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.variantComponentSelects
         */
        init = function ($scope) {
            var $selects = $('[data-variant-component-select]', $scope);

            if (_.isEmpty($selects)) { return ; }

            _.each($selects, function(select) {
                setupListener($(select));
            });
        };

    return {
        init: init
    };
}()));
