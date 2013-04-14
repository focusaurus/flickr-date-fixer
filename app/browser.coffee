class Photo extends Backbone.Model
  takenFormats = [
    "YYYY-MM-DD HH:mm:ss"
    "YYYY-MM-DD HH:mm"
    "YYYY-MM-DD HH"
    "YYYY-MM-DD"
    "YYYY-MM"
    "YYYY"
  ]
  photoPageURL: =>
    "http://www.flickr.com/photos/" +
      encodeURIComponent(@attributes?.owner) +
      "/" + encodeURIComponent @id
  title: =>
    @attributes?.title
  takenAt: =>
    takenAt = @attributes?.dates?.taken
    if takenAt
      moment(takenAt, @takenFormats).toDate()
  postedAt: =>
    posted = @attributes?.dates?.posted
    if posted
      moment.unix(posted).toDate()

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
    return "" if not date
    moment(date).format("MMM D, YYYY")
  tagName: "li"
  initialize: =>
    @listenTo this.model, "change", this.render
  present: =>
    pojo =
      id: @model.id
      photoPageURL: @model.photoPageURL()
      title: @model.title()
      takenAt: @formatDate @model.takenAt()
      postedAt: @formatDate @model.postedAt()
  render: =>
    pojo = @present()
    link = "<a href='#{pojo.photoPageURL}'>#{pojo.id} #{pojo.title}</a>"
    dates = "Taken: #{pojo.takenAt}, Posted: #{pojo.postedAt}"
    @$el.html link + dates
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
