require.config
  baseUrl: "/js"
  shim:
    lodash:
      exports: "_"
    backbone:
      deps: ["underscore", "jquery"]
      exports: "Backbone"
    jade:
      exports: "jade"
