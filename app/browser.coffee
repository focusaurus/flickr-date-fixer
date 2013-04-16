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
  thumbnailURL: =>
    "http://farm#{@attributes.farm}.staticflickr.com/#{@attributes.server}/#{@id}_#{@attributes.secret}_t.jpg"

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
      diff = mp.diff mt
      return Math.abs(diff) > (1000 * 60 * 60 * 72) #3 days
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

class PhotoList extends Backbone.View
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
