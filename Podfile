source 'https://github.com/CocoaPods/Specs.git'

install! 'cocoapods', :generate_multiple_pod_projects => true, :incremental_installation => false

platform :ios, '8.0'

inhibit_all_warnings!

def path_pods   #本地调试 pods 集
  pod 'FastDevTools', :subspecs => ['DebugManager', 'DebugFlex'] , :path => '../FastDevTools'
  pod 'GCDWebServer', :subspecs => ['Core', 'WebUploader', 'WebDAV'], :path => '../GCDWebServer'
  pod 'MLeaksFinder', :path => '../MLeaksFinder'
  
end

target 'DebugController' do
    path_pods
end



