Workarea Product Bundles
================================================================================

A Workarea Commerce plugin that adds support for product bundles. A product bundle groups together other products to be displayed on a single product detail page. This enables your storefront to display related items together and offer an easy way to quickly add all the items to cart.

Features
--------------------------------------------------------------------------------

* Adds the ability to associate products through a product bundle in the admin
* Adds a custom product bundle creation workflow to the admin
* Adds a `package` product template for the storefront that displays all the packaged products together while still allowing separate add to cart buttons for each product
* Adds a `family` product template for the storefront that displays all the packaged products together and allows adding any or all bundled products to a cart at the same time
* Adds a the concept of `kit` products, a product bundle that defines its own variants as specific combinations of bundled product SKUs, and displays as a single product through checkout.

Getting Started
--------------------------------------------------------------------------------

Add the gem to your application's Gemfile:

```ruby
# ...
gem 'workarea-product_bundles'
# ...
```

Update your application's bundle.

```bash
cd path/to/application
bundle
```

Product Bundle Types
--------------------------------------------------------------------------------

There are three types of product bundles provided through this plugin:

**Package**

A package product is the most basic product bundle type. A package displays bundled products on a single detail page where a customer can select options and add each individual product to their cart one at a time. Each product within a package product displays its own options, quantity, and add to cart button.

**Family**

A family product provides greater flexibility and a simpler shopping experience for the customer that wishes to add any or all products within a bundle to their cart. Products bundled as a family are displayed with their own options and quantity selection. However, with family there is a single add to cart button that allows a customer to decide exactly which parts of the bundle they want to purchase and can then add them all to their cart with one click.

**Kit**

A kit product defines its own set of variants, with each variant representing a specific combination of SKUs and quantities of the products bundled within it. To a customer, a kit can be displayed just like a normal product with a single set of options to select before adding the kit to their cart. The plugin provides you the option to show the bundled products to the customer after they make a selection, or leave that information hidden. A kit is added to the cart and handled like any other product through checkout. Once an order containing a kit is placed, the items within the kit are expanded out of the kit to allow for proper tracking of each item's status through fulfillment. Kits allow for unique pricing of each combination of bundled products that enables you to offer savings to customers for buying items together.

Workarea Commerce Documentation
--------------------------------------------------------------------------------

See [https://developer.workarea.com](https://developer.workarea.com) for Workarea Commerce documentation.

License
--------------------------------------------------------------------------------

Workarea Product Bundles is released under the [Business Software License](LICENSE)
