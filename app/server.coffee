_ = require "lodash"
express = require "express"
log = require "winston"
passport = require "passport"
FlickrStrategy = require("passport-flickr").Strategy
creds = require "../creds.json"

PORT = 9100

app = express()
app.set "view engine", "jade"
app.set "views", "#{__dirname}/templates"

verify = (token, tokenSecret, profile, done) ->
  user = {token, tokenSecret, profile}
  log.debug "flickr user authorized", profile
  done null, user

flickrOptions =
  consumerKey: creds.key,
  consumerSecret: creds.secret,
  callbackURL: "http://peterlyons.com:#{PORT}/auth/flickr/callback"

flickrStrategy = new FlickrStrategy flickrOptions, verify

passport.use flickrStrategy
passport.serializeUser (user, done) -> done null, user
passport.deserializeUser (obj, done) -> done null, obj

app.use express.cookieParser()
#app.use express.bodyParser()
app.use express.session { secret: 'FjybJYtL5k9RQOug6qfwSW6JaOHIgU80Qju' }
app.use passport.initialize()
app.use passport.session()

app.get "/", (req, res, next) ->
  res.locals
    user: req.user
  res.render "home"

app.get "/auth/flickr", passport.authenticate 'flickr', () -> #no-op

app.get "/auth/flickr/callback", passport.authenticate("flickr", failureRedirect: "/"), (req, res) ->
  res.redirect "/"

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

app.listen PORT, ->
  log.info "flickr date fixer listening on port #{PORT}"
