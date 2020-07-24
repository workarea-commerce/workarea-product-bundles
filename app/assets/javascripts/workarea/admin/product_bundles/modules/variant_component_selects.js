/**
 * @namespace WORKAREA.variantComponentSelects
 */
WORKAREA.registerModule('variantComponentSelects', (function () {
    'use strict';

    var filterOptions = function($select, $options) {
            var selectValue = $select.val(),
                $filteredSelect = $options.closest('select');

            if (_.isEmpty(selectValue)) {
                $filteredSelect.addClass('hidden').val('');
                return;
            } else {
                $filteredSelect.removeClass('hidden').val('');
            }

            _.each($options, function(option) {
                var $option = $(option),
                    optionValue = $option.data('variantComponentOption');

                if (optionValue === selectValue) {
                    $option.removeClass('hidden');
                } else {
                    $option.addClass('hidden');
                }
            });
        },

        setupListener = function($select) {
            var $options = $select.closest('tr').find('[data-variant-component-option]');
            $select.on('change', _.partial(filterOptions, $select, $options));
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
