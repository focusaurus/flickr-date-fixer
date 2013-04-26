define (require, exports, module) ->
  Backbone = require "backbone"
  PhotoView = require "views/Photo"

  class PhotoList extends Backbone.View
    className: "v-photos"
    initialize: =>
      @listenTo @collection, "sync", @render

    render: =>
      @$el.empty()
      @$el.append '<button class="fixAll">Fix them all!</button>'

      for photo in @collection.toArray()
        view = new PhotoView {model: photo}
        view.render()
        @$el.append view.el
      return this

  module.exports = PhotoList
