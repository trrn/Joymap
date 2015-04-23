platform :ios, '7.0'

pod 'AFNetworking',             '~>2.4'
pod 'FMDB',                     '~>2.3'
pod 'FontAwesomeIconFactory',   '~>1.2'
pod 'Google-Maps-iOS-SDK',      '~>1.9'
pod 'IDMPhotoBrowser',          '~>1.3'
pod 'MGImageUtilities',         '~>0.0'
pod 'SDWebImage',               '~>3.5'
pod 'StreamingKit',             '~>0.1'
pod 'UIView-Autolayout',        '~>0.2'
pod 'UIImage-Categories',       '~>0.0'
pod 'Underscore.m',             '~>0.2'
pod 'CRToast',                  '~>0.0'
pod 'Google-Mobile-Ads-SDK',    '~>7.1'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'Joymap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
