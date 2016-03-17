express = require('express')
cors = require('cors')
async = require('async')
bodyParser = require('body-parser')
#acceptLanguage = require('accept-language')
expressErrorResponse = require('express-response-error')
expressResponseRange = require('express-response-range')


#module.exports = {
#  all: require('./lib/all')
#  get: require('./lib/get')
#}

class JsCoreDataRouter
  constructor:(@database)->

  _defaultRouter:(entityName, options = {})->
    router = express.Router()
    router.use(require('./lib/_')(@database, entityName, options))
    return router

  all:(entityName, options = {})->
    router = @_defaultRouter(entityName, options)
    router.use(require('./lib/all')(entityName,options))
    return router

  get:(entityName, options = {})->
    router = @_defaultRouter(entityName, options)
    router.use(require('./lib/get')(entityName,options))
    return router

  post:(entityName, options = {})->
    router = @_defaultRouter(entityName, options)
    router.use(require('./lib/post')(entityName,options))
    return router

  put:(entityName, options = {})->
    router = @_defaultRouter(entityName, options)
    router.use(require('./lib/put')(entityName,options))
    return router

  delete:(entityName, options = {})->
    router = @_defaultRouter(entityName, options)
    router.use(require('./lib/delete')(entityName,options))
    return router

module.exports = JsCoreDataRouter

#  processOrderParam:(order)->
#    if order
#      order = order.split(',')
#      return order.map((x)->
#        x = x.replace(/^(-?([a-zA-Z0-9\._]\.)*)id/,'$1_id')
#        return x
#      )
#    return null
#
#  processQueryParam:(req,entity)->
#    q = req.query.q
#    if not q
#      return null
#    where = {}
#    if q
#      searchStrings = q.split(' ')
#      queryWhere = []
#      searchColumns = []
#      allFields = no
#      if req.query.fields
#        for fieldName,fieldValue of req.query.fields
#          if fieldValue not in ['SELF.*','*']
#            searchColumns.push(fieldName)
#          else
#            allFields = yes
#      else
#        allFields = yes
#      if allFields
#        for attribute in entity.getNonTransientAttributes()
#          searchColumns.push(attribute.name)
#
#      for searchString in searchStrings
#        wordWhere = []
#        for column in searchColumns
#          columnWhere = {
#            $or:[{},{}]
#          }
#          columnWhere.$or[0]['LOWER(CAST(SELF.' + column + ' AS text))?'] = searchString.toLocaleLowerCase() + '*'
#          columnWhere.$or[1]['LOWER(CAST(SELF.' + column + ' AS text))?'] = '* ' + searchString.toLocaleLowerCase() + '*'
#          wordWhere.push(columnWhere)
#        queryWhere.push({$or:wordWhere})
#      where = {$and:queryWhere}
#    return where
#
#
#
#  createRoute:(entityName,options = {})->
#    route = express.Router()
#
#    getterFunction = options.getValues or (req,item,callback)->
#      callback(null,item.getValues())
#    setterFunction = options.setValues or (req,item,values,callback)->
#      item.setValues(values)
#      callback()
#
#
#    route.use(expressErrorResponse({curlify:yes,logging:yes,stackLogging:yes}))
#    route.use(expressResponseRange({alwaysSendRange:yes}))
#    route.use(bodyParser.json({limit:'2mb'}))
#    route.use(cors({
#      allowedHeaders:'Content-Range,Content-Type,Range,Authorization',
#      exposedHeaders:'Content-Range'
#    }))
#
#
#    route.use((req,res,next)->
#      if not req.context
#        return next(new Error('req.context does not contain js-core-data context'))
#      else
#        req.entity = req.context.storeCoordinator.objectModel.getEntity(entityName)
#      next()
#    )
#
#    route.get('/',(req,res,next)=>
#
#      where = {}
#      order = @processOrderParam(req.query.order)
#
#      qWhere = @processQueryParam(req,req.entity)
#      if req.query.where and qWhere
#        where = {$and:[qWhere,req.query.where]}
#      else
#        where = req.query.where or qWhere
#
#      #      console.log(JSON.stringify(where))
#
#      fields = req.query.fields
#
#      req.context.getObjectsCount(entityName,{
#        fields:fields
#        where:where
#      }).then((itemsCount)->
#        req.context.fetch(entityName,{
#          where:where,
##          having:having,
#          fields:fields
#          limit:req.range.limit,
#          offset:req.range.offset,
#          order:order or 'SELF._id'
#          group:req.query.group
#        }).then((items)->
#          for item in items
#            item.id = item._id
#            delete item._id
#          res.sendRange(items,itemsCount)
#        )
#      ).catch(next)
#    )
#
#
#    route.post('/',(req,res,next)->
#      req.item = req.context.create(entityName)
#      setterFunction(req,req.item,req.body,next)
#    )
#    route.post('/',(req,res,next)->
#      req.context.save().then(()->
#        res.status(201)
#        getterFunction(req,req.item,(err,data)->
#          return next(err) if err
#          res.send(data)
#        )
#      ).catch(next)
#    )
#
#    route.all('/:id',(req,res,next)=>
#      req.context.getObjectWithId(entityName,parseInt(req.params.id)).then((item)->
#        if not item
#          return res.notFound(entityName + ' with id ' + req.params.id + ' not found')
#        req.item = item
#        next()
#      ).catch(next)
#    )
#    route.get('/:id',(req,res,next)->
#      getterFunction(req,req.item,(err,values)->
#        return next(err) if err
#        res.send(values)
#      )
#    )
#    route.put('/:id',(req,res,next)->
#      setterFunction(req,req.item,req.body,(err)->
#        return next(err) if err
#        req.context.save().then(()->
#          getterFunction(req,req.item,(err,values)->
#            return next(err) if err
#            res.send(values)
#          )
#        ).catch(next)
#      )
#    )
#    route.delete('/:id',(req,res,next)->
#      req.context.deleteObject(req.item)
#      req.context.save().then(()->
#        res.status(204).end()
#      ).catch(next)
#    )
#
#
#
#
#
#
#
