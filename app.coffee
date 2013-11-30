express = require('express')
path = require('path')
http = require('http')
app = express()

# all environments
app.set('port', process.env.PORT ? 80)
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'ejs')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.json())
app.use(express.urlencoded())
app.use(express.methodOverride())
app.use(express.static(path.join(__dirname, 'public')))

# development only
if ('development' == app.get('env'))
    app.use(express.errorHandler())

# DB
DbDal = require('./lib/dal/DbDal')
new DbDal.MongoDB().connect()

# routes
(new (require('./lib/routes/NameRoute'))(app)).addRequestHandlers()
(new (require('./lib/routes/AdminRoute'))(app)).addRequestHandlers()

http.createServer(app).listen(app.get('port'), ()->
    console.log('Express server listening on port ' + app.get('port'))
)