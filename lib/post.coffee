express = require('express')
Promise = require('bluebird')

module.exports = (entityName, options = {})->
  router = express.Router()

  setterFunction = options.setValues or (data)->
    data.item.setValues(data.req.body)
    return Promise.resolve()

  getter = options.getValues or (data)->
    return Promise.resolve(data.item.getValues())

  router.post('/',(req,res,next)->
    req.item = req.context.create(entityName)
    return setterFunction({req:req,item:req.item}).then(()-> next()).catch(next)
  )
  router.post('/',(req,res,next)->
    req.context.save().then(()->
      res.status(201)
      getter({req:req,item:req.item}).then((data)->
        res.send(data)
      )
    ).catch(next)
  )

  return router
