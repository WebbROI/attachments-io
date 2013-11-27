'use strict'

app = angular.module('attachments.profile', ['attachments.services'])

app.config([ '$routeProvider', '$locationProvider', '$httpProvider',
  ($routeProvider, $locationProvider, $httpProvider) ->
    $locationProvider.html5Mode(true);
    $routeProvider
    .when('/profile',
        templateUrl: '<%= asset_path "pages/profile.html" %>'
        controller: 'ProfilePageCtrl'
      )
    .otherwise();
])


app.value "Config",
  SYNC_STATUS_FINISHED: 2
  SYNC_STATUS_INPROCESS: 1
  SYNC_STATUS_ERROR: 0

app.controller('ProfilePageCtrl', [
  '$scope', 'EventSource', '$routeParams', 'API', 'Config',
  ($scope, EventSource, $routeParams, API, Config) ->
    console.log("ololo", $routeParams)
    source = EventSource
    $scope.config = Config

    API.sync.get {id: $routeParams.id}, (response) ->
      $scope.files = response.files
      $scope.sync = response.sync

      source.addEventListener('progressbar', (event) ->
        data = JSON.parse event.data
        console.log('progressbar', data)
      )

      source.addEventListener('synchronization_add_file', (event) ->
        data = JSON.parse(event.data);
        console.log('synchronization_add_file', data)
      )

      source.addEventListener('synchronization_update', (event) ->
        data = JSON.parse(event.data)
        console.log('synchronization_update', data)

      );

])