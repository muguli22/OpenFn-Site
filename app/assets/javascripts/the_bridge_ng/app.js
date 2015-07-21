// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  Array.prototype.filter = function(func) {
    var x, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      x = this[_i];
      if (func(x)) {
        _results.push(x);
      }
    }
    return _results;
  };

  this.the_bridge = angular.module('the_bridge', ['ngRoute', 'ngResource', 'ui.tree', 'ngAnimate', 'ngSanitize', 'the_bridge.controllers', 'the_bridge.directives', 'the_bridge.resources', 'the_bridge.services', 'the_bridge.filters', 'the_bridge.config', 'OpenFn', 'OpenFn.Mappings', 'OpenFn.Services', 'ui.sortable', 'ui.bootstrap', 'ng-rails-csrf', 'mgcrea.bootstrap.affix', 'angulartics', 'angulartics.google.analytics', 'angular-growl']);

  this.Legacy = {
    controllers: {},
    modules: {}
  };

  this.controllerModule = angular.module('the_bridge.controllers', []);

  this.directiveModule = angular.module('the_bridge.directives', []);

  this.resourceModule = angular.module('the_bridge.resources', []);

  this.serviceModule = angular.module('the_bridge.services', []);

  this.filterModule = angular.module('the_bridge.filters', []);

  this.configModule = angular.module('the_bridge.config', []);

  this.the_bridge.config([
    '$routeProvider', '$locationProvider', 'growlProvider', function($routeProvider, $locationProvider, growlProvider) {
      growlProvider.globalTimeToLive(3000);
      growlProvider.globalPosition('top-right');
      $locationProvider.html5Mode(true);
      if (!Features.new_mapping_page) {
        $routeProvider.when('/mappings/new', {
          controller: Legacy.controllers.NewMappingCtrl,
          templateUrl: '../the_bridge_templates/mappings/new.html'
        }).when('/mappings/:id', {
          controller: 'EditMappingCtrl',
          templateUrl: '../the_bridge_templates/mappings/edit.html',
          resolve: {
            mappingResponse: function($q, $route, Mapping) {
              var defer;
              defer = $q.defer();
              Mapping.get({
                id: $route.current.params.id
              }).$promise.then(function(response) {
                return defer.resolve(response);
              });
              return defer.promise;
            }
          }
        });
      }
      return $routeProvider.when('/metrics/organisation', {
        templateUrl: '../the_bridge_templates/metrics/organisations/index.html',
        controller: 'OrganisationsIndexCtrl'
      }).when('/marketplace', {
        templateUrl: '../the_bridge_templates/marketplace/index.html'
      }).when('/marketplace/search/:search', {
        templateUrl: '../the_bridge_templates/marketplace/index.html'
      }).when('/marketplace/search/', {
        templateUrl: '../the_bridge_templates/marketplace/index.html'
      }).when('/product/:id', {
        templateUrl: '../the_bridge_templates/product/show.html'
      }).when('/product/:id/edit', {
        templateUrl: '../the_bridge_templates/product/edit.html'
      }).when('/admin/get_drafts', {
        templateUrl: '../the_bridge_templates/product/admin.html'
      }).when('/release-notes', {
        templateUrl: '../the_bridge_templates/release_notes/index.html'
      }).when('/pricing', {
        templateUrl: '../the_bridge_templates/static/pricing.html'
      }).when('/developers', {
        templateUrl: '../the_bridge_templates/static/developers.html'
      }).when('/welcome', {
        templateUrl: '../the_bridge_templates/static/welcome2.html'
      }).when('/tags', {
        templateUrl: '../the_bridge_templates/tags/index.html'
      }).when('/register', {
        templateUrl: '../the_bridge_templates/user/user_info.html'
      }).when('/', {
        templateUrl: '../the_bridge_templates/static/welcome.html',
        controller: function($scope, $http) {
          $scope.productCount = null;
          $scope.userCount = null;
          $scope.submissionCount = null;
          $scope.productConnectedCount = null;
          return $http.get('/welcome_stats').success(function(data) {
            $scope.submissionCount = data.submissionCount;
            $scope.orgCount = data.orgCount;
            $scope.productPublicCount = data.productPublicCount;
            return $scope.productConnectedCount = data.productConnectedCount;
          });
        }
      }).otherwise({
        redirectTo: "/"
      });
    }
  ]);

}).call(this);
