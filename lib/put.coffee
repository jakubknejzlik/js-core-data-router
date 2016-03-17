express = require('express')
Promise = require('bluebird')

module.exports = (entityName, options = {})->
  router = express.Router()

  setterFunction = options.setValues or (data)->
    console.log(data.req.body,'!!!')
    data.item.setValues(data.req.body)
    return Promise.resolve()

  getter = options.getValues or (data)->
    return Promise.resolve(data.item.getValues())

  router.put('/:id',(req,res,next)->
    console.log('!!!!')
    req.context.getObjectWithId(entityName,req.params.id).then((item)->
      if not item
        return res.notFound(entityName + ' with id ' + req.params.id + ' not found')
      req.item = item
      return setterFunction({req:req,item:item})
    ).then(()-> next()).catch(next)
  )
  router.put('/:id',(req,res,next)->
    req.context.save().then(()->
      getter({req:req,item:req.item}).then((data)->
        res.send(data)
      )
    ).catch(next)
  )

  return router
