Pod::Spec.new do |s|
  s.name	= 'CEProgressHUD'
  s.version	= '1.0.0'
  s.summary	= 'Swift HUD'
  s.homepage	= 'https://github.com/Zhangyanshen/CEProgressHUD'
  s.platform	= :ios
  s.author	= {'Zhangyanshen' => 'zhangyanshen86@163.com'}
  s.ios.deployment_target = '8.0'
  s.source	= {:git => 'https://github.com/Zhangyanshen/CEProgressHUD.git',:tag => s.version}
  s.source_files= 'CEProgressHUDDemo','CEProgressHUDDemo/**/*.{swift}'
  s.resources	= 'CEProgressHUDDemo/CEProgressHUD/*.{bundle}'
  s.requires_arc= true
  s.framework	= 'UIKit'
end
