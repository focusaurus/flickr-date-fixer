class Photo extends Backbone.Model
  photoPageURL: =>
    "http://www.flickr.com/photos/" +
      encodeURIComponent(this.attributes?.owner) +
      "/" + encodeURIComponent this.id
  title: =>
    this.attributes?.title

class Photos extends Backbone.Collection
  url: "/photos"
  model: Photo

class PhotoView extends Backbone.View
  tagName: "li"
  render: =>
    console.log("@bug PhotoView rendering", this.model.title());
    link = "<a href='#{this.model.photoPageURL()}'>#{this.model.id} #{this.model.title()}</a>"
    this.$el.html link
    return this

class PhotoList extends Backbone.View
  tagName: "ul"
  className: "v-photos"
  initialize: =>
    this.listenTo this.collection, "sync", this.render

  render: =>
    this.$el.empty()
    for photo in this.collection.toArray()
      console.log("@bug PhotoList rendering view for", photo.id);
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
