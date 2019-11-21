source 'https://github.com/CocoaPods/Specs.git'
source 'git@git.afpai.com:native/ZYBSpecs.git'

install! 'cocoapods', :generate_multiple_pod_projects => true, :incremental_installation => false

platform :ios, '8.0'

inhibit_all_warnings!

def production_pods  #发布环境 pods 集
    pod 'FastDevTools', '~> 0.9.4'

end

def path_pods   #本地调试 pods 集
  pod 'FastDevTools', :subspecs => ['DebugManager', 'DebugFlex'] , :path => '../FastDevTools'
#  pod 'ZYBHybrid', :path => '../../zybhybrid'
end

target 'DebugController' do
#    use_frameworks!
    
    path_pods
#    production_pods
end



