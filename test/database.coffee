CoreData = require('js-core-data')

database = new CoreData('sqlite://:memory:',{
  logging: yes
})

model = database.createModel('v1')

model.defineEntity('User',{
  username: 'string'
  password: 'string'
})

database.setModelVersion('v1')

module.exports = database