// Generated by CoffeeScript 1.10.0
(function() {
  var CoreDataRouter, Promise, app, assert, database, express, router, supertest, test, users;

  assert = require('assert');

  express = require('express');

  Promise = require('bluebird');

  supertest = require('supertest-promised');

  CoreDataRouter = require('../index');

  database = require('./database');

  app = express();

  router = new CoreDataRouter(database);

  app.use('/users', router.all('User', {
    alwaysSendRange: true
  }));

  test = supertest(app);

  users = [
    {
      username: 'test',
      password: 'testpass'
    }, {
      username: 'John',
      password: 'Doe'
    }
  ];

  describe('test all router', function() {
    before(function(done) {
      return database.syncSchema({
        force: true
      }).then(done)["catch"](done);
    });
    it('should create user', function() {
      return Promise.map(users, function(user) {
        return test.post('/users').send(user).expect(201).expect(function(res) {
          assert.ok(res.body.id);
          return user.id = res.body.id;
        });
      });
    });
    it('should get users', function() {
      return test.get('/users').expect(200).expect(users);
    });
    it('should get user', function() {
      return test.get('/users/' + users[0].id).expect(200).expect(users[0]);
    });
    it('should update user', function() {
      users[0].username = 'Siri';
      users[0].password = '12345';
      return test.put('/users/' + users[0].id).send(users[0]).expect(200).expect(users[0]);
    });
    it('should delete user', function() {
      return test["delete"]('/users/' + users[0].id).expect(204);
    });
    return it('should not found deleted user', function() {
      return test.get('/users/' + users[0].id).expect(404);
    });
  });

}).call(this);
