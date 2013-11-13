'use strict'

app = angular.module('attachments.directives', [ 'attachments.services' ])

app.service( 'EventSource', [ ->
  new EventSource('/streaming/events')
])