define (require, exports, module) ->
  Backbone = require "backbone"
  moment = require "moment"
  _ = require "lodash"

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
      xhr = Backbone.$.ajax
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

  module.exports = Photo
