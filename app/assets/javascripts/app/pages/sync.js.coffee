'use strict'

app = angular.module('attachments.sync', ['attachments.services'])

app.config([ '$routeProvider', '$locationProvider', '$httpProvider',
  ($routeProvider, $locationProvider, $httpProvider) ->
    $locationProvider.html5Mode(true);
    $routeProvider
      .when('/object/:type/:id',
        templateUrl: '/partials/object/object',
        controller: 'ObjectPageCtrl'
      )
      .otherwise();
])