#Joymap

##Setup

###1. setup cocoapods (http://beta.cocoapods.org/?q=)  

`$ sudo gem install cocoapods`  
`$ pod install`

###2. open project  
`$ open Joymap.xcworkspace`

###3. edit Joymap/Env.plist
![env_plist.png](env_plist.png)  

|Key                    |Description                |Required|  
|:----------------------|:--------------------------|:------:|  
|ManagerURL             |manager host URL           |o|  
|DownloadAction         |jdb file will be downloaded from "ManagerURL / DownloadAction" |o|  
|User                   |login user(e-mail) for manager |o|  
|Map                    |registered map name        |o|  
|GoogleMapsAPIKey       |https://developers.google.com/maps/documentation/ios/start  |o|  
|HomeURL                |URL for Home tab           |o|  
|JDBIdentifyHeaderName  |look forward..             | |  
|GoogleMapsImageAPIKey  |look forward..             | |  

###4. put jdb file into "Supporting Files"  
![copy_jdb.png](copy_jdb.png)  

###5. add jdb file into "Copy Bundle Resources"
![copy_bundle.png](copy_bundle.png)  

