define (require, exports, module) ->
  Backbone = require "backbone"
  jade = require "jade"
  class Photo extends Backbone.View
    className: "v-photo"
    formatDate: (date) ->
      return "(loading...)" if not date
      moment(date).format("MMM D, YYYY")
    template: jade.compile """
  a(href=photoPageURL)
    img(src=thumbnailURL, title=title)
  table
    tr
      td ID
      td
        a(href=photoPageURL)= id
    tr
      td Title
      td
        a(href=photoPageURL)= title
    tr
      td Taken
      td= takenAt
    tr
      td Posted
      td= postedAt
    tr
      td(colspan="2")
        if needsFix
          button.fix Fix it!
        else
         span.OK OK
  """
    events:
      "click .fix": "fix"
    initialize: =>
      @listenTo this.model, "change", this.render
    fix: =>
      @$el.find('button').text("Fixing...").prop "disabled", true
      xhr = @model.fix()
      xhr.complete @render
    present: =>
      pojo =
        id: @model.id
        needsFix: @model.needsFix()
        photoPageURL: @model.photoPageURL()
        postedAt: @formatDate @model.postedAt()
        takenAt: @formatDate @model.takenAt()
        title: @model.title()
        thumbnailURL: @model.thumbnailURL()
    render: =>
      @$el.html @template @present()
      return this

  module.exports = Photo
