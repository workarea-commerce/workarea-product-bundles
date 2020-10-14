Workarea Product Bundles 1.0.0 (2020-10-14)
--------------------------------------------------------------------------------

*   Allow SKU selection for products with optionless variants

    BUNDLES-23

    Matt Duffy

*   Update dependency to match base system requirements


    Ben Crouse

*   Rework UX of kit variant creation

    BUNDLES-21

    Matt Duffy

*   Apply suggestions from code review

    Co-authored-by: Ben Crouse <bcrouse@workarea.com>

    Matt Duffy

*   Add more documentation on bundles to README

    BUNDLES-3

    Matt Duffy

*   Rename bundle fulfillment policy 'skip'

    BUNDLES-22

    Matt Duffy

*   Don't allow kit to be purchased if bundled products are not purchasable

    BUNDLES-17

    Matt Duffy

*   Remove CSV Messaging For Options Fields

    When workarea-commerce/workarea#497 is merged, this will ensure that the
    product bundles plugin is not attempting to use a translation that is no
    longer there. It also brings the plugin to parity with the core
    functionality of editing options.

    WORKAREA-266

    Tom Scott

*   Optimize kit variant creation


    Matt Duffy

*   Handle missing pricing skus when calculating kit variant prices

    BUNDLES-17

    Matt Duffy

*   Fix detail step views for bundle workflows to prevent type filter

    BUNDLES-20

    Matt Duffy

*   Remove storefront link from new variants step of kit workflow

    BUNDLES-18

    Matt Duffy

*   Bump lodash from 4.17.15 to 4.17.20

    Bumps [lodash](https://github.com/lodash/lodash) from 4.17.15 to 4.17.20.
    - [Release notes](https://github.com/lodash/lodash/releases)
    - [Commits](https://github.com/lodash/lodash/compare/4.17.15...4.17.20)

    Signed-off-by: dependabot[bot] <support@github.com>

    dependabot[bot]

*   fix js style


    Matt Duffy

*   Refine kit variant creation preview data

    BUNDLES-16

    Matt Duffy

*   Fix sku select filtering when selecting products for components

    BUNDLES-11

    Matt Duffy

*   Remove csv tooltip from value column of variant options


    Matt Duffy

*   Add options column to components table when editing variants

    BUNDLES-14

    Matt Duffy

*   Update Copy options label

    BUNDLES-15

    Matt Duffy

*   Automatically set fulfillment policy for new kit variants

    BUNDLES-12

    Matt Duffy

*   Defer fulfillment policy checking to bundled items for bundle in order

    BUNDLES-13

    Matt Duffy

*   Respect product product_ids order when rendering variant components

    BUNDLES-5

    Matt Duffy

*   Correct inventory messaging in featured products UI for discrete bundles

    BUNDLES-4

    Matt Duffy

*   fix missing tooltip

    BUNDLES-8

    Matt Duffy

*   Apply suggestions from code review

    Co-authored-by: Ben Crouse <bcrouse@workarea.com>

    Matt Duffy

*   PR cleanup


    Matt Duffy

*   Add admin kit workflow creation

    BUNDLES-2

    Matt Duffy

*   Add better seed data

    BUNDLES-1

    Matt Duffy

*   Rename plugin workarea-product_bundles


    Matt Duffy

*   Add kit functionality, update overall bundle behavior

    * Introduce concept of a bundle, which is any of package, family, or kit
    * Rework package and family product detail pages for better UX
    * Add kit to allow bundled products displayed as a "normal" product through checkout

    BUNDLES-1

    Matt Duffy

*   Use patched HashUpdate for localized hash fields

    Fixes an infinite loop when installed with other plugins.

    Ben Crouse

*   Fix activeness to accommodate v3.5 logic

    This also only allows a package to be active if at least one of it's
    children products are active.

    Ben Crouse

*   Initial commit on master


    Curt Howard



Workarea Package Products 3.4.1 (2020-04-20)
--------------------------------------------------------------------------------

*   Use patched HashUpdate for localized hash fields

    Fixes an infinite loop when installed with other plugins.
    Ben Crouse



Workarea Package Products 3.3.1 (2019-04-16)
--------------------------------------------------------------------------------

*   Fix pricing method being private

    This isn't private on the base `Storefront::ProductViewModel` so it
    shouldn't be private in this view model.

    PACKAGEPDP-58
    Ben Crouse



Workarea Package Products 3.3.0 (2019-03-13)
--------------------------------------------------------------------------------

*   Fix reference to deprecated testing product template

    This was removed from base in v3.4 since we have some out of the box
    templates you can use now.
    Ben Crouse

*   Fix test for v3.4 insights changes

    Ben Crouse

*   Require Workarea 3.4 to fix testing dependency

    This plugin overrides a test needed in v3.4 that won't pass in earlier
    minors, so this should be enforced in the dependencies.
    Ben Crouse

*   Add via param for metrics tracking

    ECOMMERCE-6630
    Ben Crouse

*   Add product-details__heading class for direct styling hook

    ECOMMERCE-6363
    Curt Howard

*   Update for workarea v3.4 compatibility

    PACKAGEPDP-55
    Matt Duffy



Workarea Package Products 3.2.1 (2018-10-03)
--------------------------------------------------------------------------------

*   Prevent Exception When Adding "Displayable When Out Of Stock" Product in Family to Cart

    Products using the `DisplayableWhenOutOfStock` policy which were not
    actually available to sell caused an exception when a user attempted to
    add them to cart. Workarea now prevents this error by ensuring that all
    order items passed into the `AddPackageToCart` command are actually in
    the order (since inventory checks may have removed items due to being
    out of stock) before rendering order items to the screen in the cart.

    PACKAGEPDP-50
    Tom Scott

*   Compact filters in seeds

    If the products are created from other sample data where there isn't any
    color or size filters, the seeds would create a filter where the value
    was `[nil]`, breaking analytics seeds.

    PACKAGEPDP-53
    Eric Pigeon

*   Fix JS linting

    ECOMMERCE-6125
    Ben Crouse



Workarea Package Products 3.2.0 (2018-05-24)
--------------------------------------------------------------------------------

*   Update worflow view to link to new import page, setup for minor.

    PACKAGEPDP-52
    Matt Duffy

*   Leverage Workarea Changelog task

    ECOMMERCE-5355
    Curt Howard



Workarea Package Products 3.1.4 (2018-02-20)
--------------------------------------------------------------------------------

*   Add append point to alt images on package and family template

    * Allow plugins, such as product videos, to append alt images to the PDP

    PACKAGEPDP-47
    Jake Beresford

*   Lock plugin down to Workarea v3.0.x

    PACKAGEPDP-43
    Curt Howard

*   Remove duplicate IDs in add to cart dialog confirmation

    Fixes failing test

    PACKAGEPDP-38
    Curt Howard


Workarea Package Products 3.1.3 (2018-01-09)
--------------------------------------------------------------------------------

*   Add ids to fields to prevent duplicate ids, update template test for plugin friendliness

    PACKAGEPDP-45
    Matt Duffy

*   Fix packaged generic product inline refresh

    When the generic product template refreshes itself upon a SKU change, it
    was replacing the `.product-details` element on the page with one that
    didn't include a `data-packaged-product-id`, thus causing the JS module
    that adds packaged products in a family to the cart to think that the
    item was not actually selected. We're now wrapping the
    `.product-details` for each packaged product with a
    `.packaged-product-details` element that includes the
    `data-packaged-product-id`, ensuring that the ID will always be on the
    page right after the checkbox.

    PACKAGEPDP-44
    Tom Scott


Workarea Package Products 3.1.2 (2017-10-03)
--------------------------------------------------------------------------------

*   Fix pageview event firing for package products.

    The package product was being passed into the analytics helper for each product within the package.
    This caused the pageview event to be fired on the package product the same number of times as products within the package.
    Products within the package are now sending the appropriate product to the analytics helper

    PACKAGEPDP-28
    Brian Berg


Workarea Package Products 3.1.1 (2017-09-26)
--------------------------------------------------------------------------------

*   Standardize plugin configuration

    PACKAGEPDP-41
    Matt Duffy


Workarea Package Products 3.1.0 (2017-09-15)
--------------------------------------------------------------------------------

*   Fix headings in package product create workflow

    PACKAGEPDP-39
    Curt Howard

*   Remove duplicate IDs in add to cart dialog confirmation

    Fixes failing test

    PACKAGEPDP-38
    Curt Howard

*   Remove product id from packages when packaged product is deleted

    PACKAGEPDP-36
    Matt Duffy

*   Add logic to handle copying package products properly

    PACKAGEPDP-34
    Matt Duffy


Workarea Package Products 3.0.5 (2017-09-26)
--------------------------------------------------------------------------------

*   Standardize plugin configuration

    PACKAGEPDP-41
    Matt Duffy


Workarea Package Products 3.0.4 (2017-09-06)
--------------------------------------------------------------------------------

*   Remove product id from packages when packaged product is deleted

    PACKAGEPDP-36
    Matt Duffy


Workarea Package Products 3.0.3 (2017-06-08)
--------------------------------------------------------------------------------

*   Fix missing translations

    PACKAGEPDP-33
    Dave Barnow


Workarea Package Products 3.0.2 (2017-05-26)
--------------------------------------------------------------------------------

*   Move seeds config to an initializer, seed after product data

    PACKAGEPDP-31
    Dave Barnow


Workarea Package Products 3.0.1 (2017-05-19)
--------------------------------------------------------------------------------

*   Fix broken base tests

    PACKAGEPDP-30
    Ben Crouse

*   Adjust Admin::ProductViewModel#templates to not require a model

    PACKAGEPDP-27
    Matt Duffy


Workarea Package Products 3.0.0 (2017-05-04)
--------------------------------------------------------------------------------

* Update for workarea v3 compatiblity


WebLinc Package Products 2.0.0 (2016-10-12)
--------------------------------------------------------------------------------

*   Fix package products indexing errors

    Package products are being saved in the admin with an empty string as one of the packaged product ids. This causes the indexing to break since there is a hard find in the product mapper for package products to grab all the packaged products by id.

    Add: Validation to clean up all blank entries in the packaged_product_ids field

    PACKAGEPDP-18
    David Freiman

*   Restrict results for packaged products to exclude other package products.

    PACKAGEPDP-13
    Matt Duffy

*   Add a note to Package Product's Active toggle

    PACKAGEPDP-3
    Curt Howard

*   Ensure ordering of packaged products is consistent throughout app

    PACKAGEPDP-9
    Matt Duffy

*   Isolate template types between standard and package products.

    PACKAGEPDP-10
    Matt Duffy

*   Resolve issues with package product editing and display.

    PACKAGEPDP-4
    fixes: PACKAGEPDP-5, PACKAGEPDP-7, PACKAGEPDP-8
    Matt Duffy


WebLinc Package Products 1.0.3 (2016-09-13)
--------------------------------------------------------------------------------

*   Fix package products indexing errors

    Package products are being saved in the admin with an empty string as one of the packaged product ids. This causes the indexing to break since there is a hard find in the product mapper for package products to grab all the packaged products by id.

    Add: Validation to clean up all blank entries in the packaged_product_ids field

    PACKAGEPDP-18
    David Freiman


WebLinc Package Products 1.0.2 (2016-04-05)
--------------------------------------------------------------------------------


WebLinc Package Products 1.0.1 (2016-03-11)
--------------------------------------------------------------------------------

*   Namespace product decorator

    Product decorator is missing `with` keyword argument. Add the argument
    to properly namespace the decorator to the plugin.

    PACKAGEPDP-1
    Chris Cressman


WebLinc Package Products 1.0.0 (2016-01-13)
--------------------------------------------------------------------------------

*   First release
