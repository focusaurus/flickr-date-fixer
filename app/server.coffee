_ = require "lodash"
creds = require "../creds.json"
crypto = require "crypto"
express = require "express"
FlickrStrategy = require("passport-flickr").Strategy
log = require "winston"
passport = require "passport"
querystring = require "querystring"
request = require "superagent"
{Flickr} = require "flickr"

API_URL = "http://api.flickr.com/services/rest"
PORT = 9100
flickrOptions =
  consumerKey: creds.key,
  consumerSecret: creds.secret,
  callbackURL: "http://peterlyons.com:#{PORT}/auth/flickr/callback"

#This hacks in a hard-coded set of auth data for rapid-turnaround
#dev mode
_devMode = (req, res, next) ->
  req.user = creds.devUser
  next()

verify = (token, tokenSecret, profile, done) ->
  console.log("@bug auth", token, tokenSecret, profile);
  log.debug "flickr user authorized", profile
  user = {token, tokenSecret, profile}
  done null, user

loggedIn = (req, res, next) ->
  if not req.user
    return res.status(401).send "You must log in to do that"
  res.locals
    user: req.user
  req.flickr = new Flickr creds.key, creds.secret
  req.flickr.setOAuthTokens req.user.token, req.user.tokenSecret
  next()

buildParams = (params) ->
  data = _.defaults params,
    format: "json"
    nojsoncallback: "1"
    user_id: "me"
    api_key: creds.key
  paramList = []
  _.each data, (value, key) -> paramList.push [key, value]
  paramList = _.sortBy paramList, (pair) -> pair[0]
  toSign = [creds.secret]
  query = []
  _.each paramList, (pair) ->
    toSign.push encodeURIComponent(pair[0])
    toSign.push encodeURIComponent(pair[1])
    query.push encodeURIComponent(pair[0])
    query.push "="
    query.push encodeURIComponent(pair[1])
    query.push "&"
  toSign = toSign.join ""
  hash = crypto.createHash "md5"
  hash.update toSign
  apiSignature = hash.digest "hex"
  query.push "api_sig="
  query.push apiSignature
  "?" + query.join ""


app = express()
app.set "view engine", "jade"
app.set "views", "#{__dirname}/templates"


flickrStrategy = new FlickrStrategy flickrOptions, verify

passport.use flickrStrategy
passport.serializeUser (user, done) -> done null, user
passport.deserializeUser (obj, done) -> done null, obj

app.use express.cookieParser()
#app.use express.bodyParser()
app.use express.session { secret: 'FjybJYtL5k9RQOug6qfwSW6JaOHIgU80Qju' }
app.use passport.initialize()
app.use passport.session()
#@bug
app.use _devMode

app.get "/", (req, res, next) ->
  res.locals
    user: req.user
  res.render "home"

app.get "/auth/flickr", passport.authenticate 'flickr', () -> #no-op

app.get "/auth/flickr/callback", passport.authenticate("flickr", failureRedirect: "/"), (req, res) ->
  res.redirect "/"

app.get "/photosOLD", loggedIn, (req, res) ->
  queryString = buildParams
    method: "flickr.people.getPhotos"
    min_date_taken: "2002-12-08"
    max_date_taken: "1002-12-09"
    content_type: "1" #photos only
    auth_token: req.user.token

  #@bug testing simpler method
  queryString = buildParams
    method: "flickr.people.getInfo"
    auth_token: req.user.token
  url = API_URL + queryString
  log.debug "URL: #{url}"
  request.get(url).end (answer) ->
    console.log("@bug flickr response", answer.text);
    res.render "home"

app.get "/photosOLD2", loggedIn, (req, res) ->
  req.flickr.executeAPIRequest "flickr.test.login", {}, true, (error, answer) ->
    console.log("@bug API done", error, answer);
    res.render "home"

app.get "/photos", loggedIn, (req, res) ->
  params =
    min_date_taken: "2002-12-08"
    max_date_taken: "2002-12-09"
    content_type: "1" #photos only
    user_id: "me"
  req.flickr.executeAPIRequest "flickr.people.getPhotos", params, true, (error, answer) ->
    console.log("@bug API done", error, answer);
    res.locals {photos: answer.photos.photo}
    res.render "photos"

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

app.listen PORT, ->
  log.info "flickr date fixer listening on port #{PORT}"
