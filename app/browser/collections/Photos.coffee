define (require, exports, module) ->
  Backbone = require "backbone"
  Photo = require "models/Photo"

  class Photos extends Backbone.Collection
    url: "/photos"
    model: Photo

  module.exports = Photos
