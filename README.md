# js-core-data-router

# Example (GET/POST/PUT methods)

```
app.use('/users',coreRouter.ALL('User',{
  getValues:(req,item,callback)->
    item.getPublicValues(req,callback)
  setValues:(req,item,values,callback)->
    item.setPublicValues(values,callback)
}))
```