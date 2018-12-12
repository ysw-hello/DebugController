source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

inhibit_all_warnings!

def production_pods  #发布环境 pods 集
    pod 'FastDevTools', '~> 0.7.3'

end

def path_pods   #本地调试 pods 集
    pod 'FastDevTools', :path => '../FastDevTools'

end

target 'DebugController' do
    use_frameworks!
    
    pod 'LDNetDiagnoService', :git =>  'https://github.com/Lede-Inc/LDNetDiagnoService_IOS.git'

#    pod 'RealReachability'

    path_pods
#    production_pods
end

