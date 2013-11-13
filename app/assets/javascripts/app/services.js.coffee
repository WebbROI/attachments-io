'use strict'

app = angular.module('attachments.services', [ 'ngResource' ])

app.service( 'EventSource', [ ->
  new EventSource('/streaming/events')
])