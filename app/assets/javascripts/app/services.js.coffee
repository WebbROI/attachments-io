'use strict'

app = angular.module('attachments.services', [ 'ngResource' ])

app.service( 'EventSource', [ ->
  new EventSource('/streaming/events')
])

app.factory( 'API', [
  '$resource',
  ($resource) ->
    sync: $resource('/sync/details/:id.json')
])