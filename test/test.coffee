assert = require('assert')
express = require('express')
Promise = require('bluebird')
supertest = require('supertest-promised')

CoreDataRouter = require('../index')
database = require('./database')

app = express()
router = new CoreDataRouter(database)

app.use('/users',router.all('User',{alwaysSendRange: yes}))

test = supertest(app)

users = [
  {username:'test',password:'testpass'}
  {username:'John',password:'Doe'}
]
describe('test all router',()->
  before((done)->
    database.syncSchema({force:yes}).then(done).catch(done)
  )

  it('should create user',()->
    return Promise.map(users,(user)->
      return test.post('/users')
      .send(user)
      .expect(201)
      .expect((res)->
        assert.ok(res.body.id)
        user.id = res.body.id
      )
    )
  )
  it('should get users',()->
    test.get('/users')
    .expect(200)
    .expect(users)
  )
  it('should get user',()->
    test.get('/users/' + users[0].id)
    .expect(200)
    .expect(users[0])
  )
  it('should update user',()->
    users[0].username = 'Siri'
    users[0].password = '12345'
    test.put('/users/' + users[0].id)
    .send(users[0])
    .expect(200)
    .expect(users[0])
  )
  it('should delete user',()->
    test.delete('/users/' + users[0].id)
    .expect(204)
  )
  it('should not found deleted user',()->
    test.get('/users/' + users[0].id)
    .expect(404)
  )
)