Workarea Package Products 3.3.2 (2019-06-25)
--------------------------------------------------------------------------------

*   Omit Browse Option Products From Packaged Product Search Indexing

    When a packaged product is updated in the search index, prevent an error
    being thrown when one of the IDs given in `Catalog::Product#product_ids`
    is a browse option of a parent product. These products already appear in
    the index, so there's no need to throw an error if it cann't be found.
    Instead of using a `.find` and passing an Array of IDs in, use an `$in`
    query with `.where` to find all products matching the array of IDs,
    omitting any that don't exist.

    PACKAGEPDP-59
    Tom Scott



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
