_ = require "lodash"
creds = require "../creds.json"
express = require "express"
coffeeMW = require "connect-coffee-script"
FlickrStrategy = require("passport-flickr").Strategy
log = require "winston"
passport = require "passport"
{Flickr} = require "flickr"
stylus = require "stylus"

PORT = 9100
flickrOptions =
  consumerKey: creds.key,
  consumerSecret: creds.secret,
  callbackURL: "http://peterlyons.com:#{PORT}/auth/flickr/callback"
  userAuthorizationURL: "http://www.flickr.com/services/oauth/authorize?perms=write"

#This hacks in a hard-coded set of auth data for rapid-turnaround
#dev mode
_devMode = (req, res, next) ->
  req.user = creds.devUser
  next()

verify = (token, tokenSecret, profile, done) ->
  log.debug "flickr user authorized", profile
  user = {token, tokenSecret, profile}
  done null, user

loggedIn = (req, res, next) ->
  res.locals
    user: req.user
  if not req.user
    return res.status(401).redirect "/"
  req.flickr = new Flickr creds.key, creds.secret
  req.flickr.setOAuthTokens req.user.token, req.user.tokenSecret
  next()

flickrStrategy = new FlickrStrategy flickrOptions, verify
##### setup express #####
app = express()
app.set "view engine", "jade"
app.set "views", "#{__dirname}/templates"
app.use express.cookieParser()
app.use express.session { secret: 'FjybJYtL5k9RQOug6qfwSW6JaOHIgU80Qju' }

##### setup passport #####
passport.use flickrStrategy
passport.serializeUser (user, done) -> done null, user
passport.deserializeUser (obj, done) -> done null, obj
app.use passport.initialize()
app.use passport.session()
app.use coffeeMW
  src: __dirname
  dest: __dirname + "/../generated/js"
  prefix: "/js"

##### stylus setup #####
stylusOptions =
  src: "#{__dirname}/browser"
  dest: "#{__dirname}/../generated"
  force: true
app.use stylus.middleware stylusOptions

app.use express.static "#{__dirname}/../generated/rjs"
app.use express.static "#{__dirname}/../generated"
app.use express.static "#{__dirname}/../static"
app.use _devMode if creds.devMode

app.get "/", (req, res, next) ->
  res.locals
    user: req.user
  res.render "home"

app.get "/auth/flickr", passport.authenticate 'flickr', -> #no-op

app.get "/auth/flickr/callback", passport.authenticate("flickr", failureRedirect: "/"), (req, res) ->
  res.redirect "/photos"

app.get "/photos", loggedIn, (req, res) ->
  if req.xhr
    params =
      min_taken_date: "2002-12-08 12:00:00"
      max_taken_date: "2002-12-08 12:00:01"
      content_type: "1" #photos only
      user_id: "me"
    req.flickr.executeAPIRequest "flickr.people.getPhotos", params, true, (error, answer) ->
      return res.status(500).send(error) if error
      res.send answer.photos.photo
  else
    return res.render "photos"

app.get "/photos/:id/info", loggedIn, (req, res) ->
  params =
    photo_id: req.params.id
  req.flickr.executeAPIRequest "flickr.photos.getInfo", params, true, (error, answer) ->
    res.send answer.photo

app.put "/photos/:id/setDates", loggedIn, express.bodyParser(), (req, res) ->
  params =
    photo_id: req.params.id
    date_taken: req.body.date_taken
  req.flickr.executeAPIRequest "flickr.photos.setDates", params, true, (error, answer) ->
    return res.status(500).send(error) if error
    res.send answer

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

app.listen PORT, ->
  log.info "flickr date fixer listening on port #{PORT}"
