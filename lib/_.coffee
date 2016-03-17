express = require('express')
bodyParser = require('body-parser')
expressErrorResponse = require('express-response-error')
cors = require('cors')

module.exports = (database, entityName, options = {})->
  router = express.Router()

  router.use(expressErrorResponse(options.error)) #{curlify:yes,logging:yes,stackLogging:yes}
  router.use(bodyParser.json({limit:'2mb'}))
  router.use(cors({
    allowedHeaders:'Content-Range,Content-Type,Range,Authorization',
    exposedHeaders:'Content-Range'
  }))

  router.use((req,res,next)->
    if not req.context and database
      database.middleware()(req,res,next)
    else
      next()
  )

  router.use((req,res,next)->
    if not req.context
      return next(new Error('req.context does not contain js-core-data context'))
    else
      req.entity = req.context.storeCoordinator.objectModel.getEntity(entityName)
    next()
  )

  return router
