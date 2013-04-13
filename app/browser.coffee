class Photo extends Backbone.Model
  photoPageURL: =>
    "http://www.flickr.com/photos/" +
      encodeURIComponent(this.attributes?.owner) +
      "/" + encodeURIComponent this.id
  title: =>
    this.attributes?.title
  takenAt: =>
    this.attributes?.dates?.taken
  postedAt: =>
    this.attributes?.dates?.posted
  fetchInfo: =>
    self = this
    xhr = this.sync "read", this, url: "#{this.url()}/info"
    xhr.done (response) ->
      self.set "dates", response.dates
    xhr

class Photos extends Backbone.Collection
  url: "/photos"
  model: Photo

class PhotoView extends Backbone.View
  initialize: =>
    this.listenTo this.model, "change", this.render
  tagName: "li"
  render: =>
    link = "<a href='#{this.model.photoPageURL()}'>#{this.model.id} #{this.model.title()}</a>"
    dates = "Taken: #{this.model.takenAt()}, Posted: #{this.model.postedAt()}"
    this.$el.html link + dates
    return this

class PhotoList extends Backbone.View
  tagName: "ul"
  className: "v-photos"
  initialize: =>
    this.listenTo this.collection, "sync", this.render

  render: =>
    this.$el.empty()
    for photo in this.collection.toArray()
      view = new PhotoView {model: photo}
      view.render()
      this.$el.append view.el
    return this

window.App = {
  Photo
  Photos
  PhotoView
  PhotoList
}
