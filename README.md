# js-core-data-router

# Example (GET/POST/PUT methods)

```
router = new CoreDataRouter()

app.use('/users',router.all('User',{
  getValues:(req,item,callback)->
    item.getPublicValues(req,callback)
  setValues:(req,item,values,callback)->
    item.setPublicValues(values,callback)
}))
```