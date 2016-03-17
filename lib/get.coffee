express = require('express')
cors = require('cors')
async = require('async')
#bodyParser = require('body-parser')
#acceptLanguage = require('accept-language')
#expressErrorResponse = require('express-response-error')
expressResponseRange = require('express-response-range')


processOrderParam = (order)->
  if order
    order = order.split(',')
    return order.map((x)->
      x = x.replace(/^(-?([a-zA-Z0-9\._]\.)*)id/,'$1_id')
      return x
    )
  return null

processQueryParam = (req,entity)->
  q = req.query.q
  if not q
    return undefined
  where = {}
  if q
    searchStrings = q.split(' ')
    queryWhere = []
    searchColumns = []
    allFields = no
    if req.query.fields
      for fieldName,fieldValue of req.query.fields
        if fieldValue not in ['SELF.*','*']
          searchColumns.push(fieldName)
        else
          allFields = yes
    else
      allFields = yes
    if allFields
      for attribute in entity.getNonTransientAttributes()
        searchColumns.push(attribute.name)

    for searchString in searchStrings
      wordWhere = []
      for column in searchColumns
        columnWhere = {
          $or:[{},{}]
        }
        columnWhere.$or[0]['LOWER(CAST(SELF.' + column + ' AS text))?'] = searchString.toLocaleLowerCase() + '*'
        columnWhere.$or[1]['LOWER(CAST(SELF.' + column + ' AS text))?'] = '* ' + searchString.toLocaleLowerCase() + '*'
        wordWhere.push(columnWhere)
      queryWhere.push({$or:wordWhere})
    where = {$and:queryWhere}
  return where


module.exports = (entityName, options = {})->
  router = express.Router()

  getter = options.getValues or (data)->
    return Promise.resolve(data.item.getValues())

  router.use(expressResponseRange(options))

  router.get('/',(req,res,next)=>
    where = {}
    order = processOrderParam(req.query.order)

    qWhere = processQueryParam(req,req.entity)
    if req.query.where and qWhere
      where = {$and:[qWhere,req.query.where]}
    else
      where = req.query.where or qWhere

    #      console.log(JSON.stringify(where))

    fields = req.query.fields

    req.context.getObjectsCount(entityName,{
      fields:fields
      where:where
    }).then((itemsCount)->
      req.context.fetch(entityName,{
        where:where,
#          having:having,
        fields:fields
        limit:req.range.limit,
        offset:req.range.offset,
        order:order or 'SELF._id'
        group:req.query.group
      }).then((items)->
        for item in items
          item.id = item._id
          delete item._id
        res.sendRange(items,itemsCount)
      )
    ).catch(next)
  )

  router.get('/:id',(req,res,next)->
    req.context.getObjectWithId(entityName,req.params.id).then((item)->
      if not item
        res.notFound(entityName + ' with id ' + req.params.id + ' not found')
      getter({item:item,req:req}).then((data)->
        res.send(data)
      )
    ).catch(next)
  )
