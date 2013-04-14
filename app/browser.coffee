_.templateSettings =
  interpolate: /\{\{(.+?)\}\}/g

class Photo extends Backbone.Model
  photoPageURL: =>
    "http://www.flickr.com/photos/" +
      encodeURIComponent(@attributes?.owner) +
      "/" + encodeURIComponent @id
  title: =>
    @attributes?.title
  takenAt: =>
    takenAt = @attributes?.dates?.taken
    if takenAt
      moment(takenAt, "YYYY-MM-DD HH:mm:ss").toDate()
  postedAt: =>
    posted = @attributes?.dates?.posted
    if posted
      moment.unix(posted).toDate()
  fix: =>
    self = @
    mp = moment.unix(@attributes?.dates?.posted)
    data =
      date_taken: mp.format "YYYY-MM-DD HH:mm:ss"
      photo_id: @id
    success = ->
      newDates = _.clone self.attributes.dates
      newDates.taken = data.date_taken
      self.set "dates", newDates
    xhr = $.ajax
      type: "PUT"
      url: "#{@url()}/setDates"
      contentType: "application/json; charset=utf-8"
      dataType: "JSON"
      data: JSON.stringify data
      success: success
    return xhr
  needsFix: =>
    takenAt = @takenAt()
    postedAt = @postedAt()
    if takenAt and postedAt
      mt = moment(takenAt)
      mp = moment(postedAt)
      diff = mt.diff mp
      return diff < 1000 * 60 * 60 * 72
    else
      return true

  fetchInfo: =>
    self = this
    xhr = @sync "read", this, url: "#{@url()}/info"
    xhr.done (response) ->
      self.set "dates", response.dates
    xhr

class Photos extends Backbone.Collection
  url: "/photos"
  model: Photo

class PhotoView extends Backbone.View
  formatDate: (date) ->
    return "(loading...)" if not date
    moment(date).format("MMM D, YYYY")
  tagName: "li"
  template: jade.compile """
a(href=photoPageURL)= id + " " + title
= "Taken: " + takenAt + " "
= "Posted: " + postedAt
if needsFix
  button.fix Fix it!
else
 = OK
"""
  events:
    "click .fix": "fix"
  initialize: =>
    @listenTo this.model, "change", this.render
  fix: =>
    @model.fix()
  present: =>
    pojo =
      id: @model.id
      needsFix: @model.needsFix()
      photoPageURL: @model.photoPageURL()
      postedAt: @formatDate @model.postedAt()
      takenAt: @formatDate @model.takenAt()
      title: @model.title()
  render: =>
    @$el.html @template @present()
    return this

class PhotoList extends Backbone.View
  tagName: "ul"
  className: "v-photos"
  initialize: =>
    @listenTo @collection, "sync", @render

  render: =>
    @$el.empty()
    for photo in @collection.toArray()
      view = new PhotoView {model: photo}
      view.render()
      @$el.append view.el
    return this

window.App = {
  Photo
  Photos
  PhotoView
  PhotoList
}
