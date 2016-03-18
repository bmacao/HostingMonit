var demo = angular.module('admin', ['iso.directives', 'hljs'])
        .controller('MainCtrl', function ($scope, $http ,$interval) {
            $http.get("data/data.json")
                    .success(function (response) {
                        $scope.names = response;
						
                    });
			
				$interval(function(){
						$http.get("data/data.json")
							.success(function (response) {
								$scope.names = response;
								$scope.date = new Date();
								$scope.$apply();
					});
					},30000);
        });