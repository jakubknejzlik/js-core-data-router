// Generated by CoffeeScript 1.10.0
(function() {
  var CoreData, database, model;

  CoreData = require('js-core-data');

  database = new CoreData('sqlite://:memory:', {
    logging: true
  });

  model = database.createModel('v1');

  model.defineEntity('User', {
    username: 'string',
    password: 'string'
  });

  database.setModelVersion('v1');

  module.exports = database;

}).call(this);
