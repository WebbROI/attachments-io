'use strict'

app = angular.module('attachments.profile', ['attachments.services'])

app.config([ '$routeProvider', '$locationProvider', '$httpProvider',
  ($routeProvider, $locationProvider, $httpProvider) ->
    $locationProvider.html5Mode(true);
    $routeProvider
    .when('/profile',
        templateUrl: '/partials/object/object',
        controller: 'ObjectPageCtrl'
      )
    .otherwise();
])