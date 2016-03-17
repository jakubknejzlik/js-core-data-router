express = require('express')

module.exports = (entityName, options = {})->
  router = express.Router()

  router.use(require('./get')(entityName, options))
  router.use(require('./post')(entityName, options))
  router.use(require('./put')(entityName, options))
  router.use(require('./delete')(entityName, options))

  return router