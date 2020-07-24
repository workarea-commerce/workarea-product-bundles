/**
 * @namespace WORKAREA.filterable
 */
WORKAREA.registerModule('filterable', (function () {
    'use strict';

    var updateCounter = function($el, $items) {
            var count = 0;

            if (!$el) { return; }

            count = _.reduce($items, function(sum, item) {
                return $(item).hasClass('hidden') ? sum : (sum + 1);
            }, 0);

            $el.text(
                I18n.t('workarea.admin.filterable.showing', { count: count })
            );
        },

        filterList = function($items, $counter, event) {
            var $filter = $(event.target),
                filterValue = _.filter(
                    $filter.val().toLowerCase().split(','),
                    function(val) { return !_.isEmpty(val); }
                );

            if (_.isEmpty(filterValue)) {
                _.each($items, function(item) { $(item).removeClass('hidden'); });
            } else {
                _.each($items, function(item){
                    var $item = $(item),
                        filterString = $item.data('filterable').value,
                        matches = _.some(filterValue, function(val) {
                            return filterString.includes(val);
                        });

                    matches ? $item.removeClass('hidden') : $item.addClass('hidden');
                });
            }

            updateCounter($counter, $items);
        },

        setupListener = function($items, field) {
            var $field = $(field),
                data = $field.data('filterableInput'),
                $groupItems = _.filter($items, function(item) {
                    return ($(item).data('filterable').group === data.group);
                }),
                $counter;

            if ( ! _.isEmpty(data.counter)) {
                $counter = $(data.counter);
            }

            updateCounter($counter, $groupItems);
            $field.on('keyup', _.partial(filterList, $groupItems, $counter));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.filterable
         */
        init = function ($scope) {
            var $fields = $('[data-filterable-input]', $scope),
                $items = $('[data-filterable]', $scope);

            if (_.isEmpty($fields)) { return ; }

            _.each($fields, _.partial(setupListener, $items));
        };

    return {
        init: init
    };
}()));
