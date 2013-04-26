require.config
  baseUrl: "/js"
  shim:
    lodash:
      exports: "_"
    backbone:
      deps: ["lodash", "jquery"]
      exports: "Backbone"
    jade:
      exports: "jade"
  map:
    underscore: "lodash"
