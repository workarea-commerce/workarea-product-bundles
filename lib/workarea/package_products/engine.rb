module Workarea
  module PackageProducts
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::PackageProducts
    end
  end
end
