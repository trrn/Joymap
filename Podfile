platform :ios, '7.0'
pod 'Google-Maps-iOS-SDK',      '~>1.5'
pod 'FontAwesomeIconFactory',   '~>1.2'
pod 'FMDB',                     '~>2.3'
pod 'UIView-Autolayout',        '~>0.0'
#pod 'SDWebImage',               '~>3.5'
pod 'MGImageUtilities',         '~>0.0'
pod 'IDMPhotoBrowser',          '~>1.3'
pod 'StreamingKit',             '~>0.1'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'Joymap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
