# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def shared_pods
  pod 'Alamofire', '~> 4.8.1'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'DeepDiff', '~> 2.2.0'
end

target 'GalleryExerciseApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  shared_pods

  target 'GalleryExerciseUnitTests' do
    shared_pods
    
    pod 'InstantMock', '~> 2.5.1'
    pod 'OHHTTPStubs', '~> 8.0.0'
    
  end

end
