express = require('express')

module.exports = (entityName, options = {})->
  router = express.Router()

  router.delete('/:id',(req,res,next)->
    req.context.getObjectWithId(entityName,req.params.id).then((item)->
      if not item
        res.notFound(entityName + ' with id ' + req.params.id + ' not found')
      req.context.deleteObject(item)
      return req.context.save()
    ).then(()->
      res.status(204).end()
    ).catch(next)
  )

  return router
