# --
# attachments app (angular directives, services, controllers)
# --

app = angular.module 'attachments', []

app.run ($rootScope)->
  console.log "RUN", $rootScope

app.service( 'EventSource', [ ->
  new EventSource('/streaming/events')
])

app.controller('SyncCtrl', ['$scope', 'EventSource', ($scope, EventSource) ->
  console.log("ololo");
  console.debug(EventSource)
])
