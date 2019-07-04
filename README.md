Environment Selector v.0.0.2
================
# About

Pretty basic tool to help with the testers to swap environments really quickly without having to download a specific build.  
Displays a button in the top right corner that when selected,  
displays an alert with the given possible backend environments that the user can select.  

# Usage 

Select the button and an alert with the given environments will show up,  
select the environment that you would like to use and simply restart the app.  
Also, you can drag the button across the screen. Position it as you wish.  

# Developer Implementation
 
Create an instance of the class(preferebly in the AppDelegate didFinishLaunchingWithOptions method) and pass it with the  
custom object that holds your list of environments, any logic that you would want to be executed after  
you selected your new environment should be added in the completion handler of the object's constructor.  

1. Declaration :

```swift
EnvironmentChangerController(envs: <T>, buttonImage: <UIImage?>, buttonTitle: <String?>, <completionHandler (<T>) -> (Void))  
```

2. Parameters:
• ```envs: <T>``` object that holds the environments you wish to change.  
-- Note: ```<T>``` object has to be of type String, CaseIterable to work.     
• ```buttonImage: <UIImage?>``` - If not passed, the parameter sets itself to nil and will not be read.  
• ```buttonTitle: <String?>```  - If not passed, the parameter sets itself to 'EN' and will be displayed as the button title.  
• ```completionHandler: <T> -> (Void)``` - Returns the T object associated when selected, also any logic you would like to execute after the new environment is selected you should add it here.  

3. Functions:  
```swift
• getSavedEnvironment() -> String
```

- Access the saved environment via this function.  
- Note: It saves the chosen environment in UserDefaults.  

4. Example with enums:  

```swift 
enum Envs: String, CaseIterable {
case Production = "my.production.env"
case Development = "my.development.env"
}

let envChanger = EnvironmentChangerController(envs: Envs.self) { selectedEnvironment in  

ACTIVE_ENVIRONMENT = envChanger.getSavedEnvironment()  
/// Logout user, re-instantiate server connection etc...  
}
```

5. Notes when implementing:  
• If no button image/title is passed in the constructor, by default it will set the button title to 'EN'.  
• If a button title AND image is specified, the image is implemented and the title set will not be set. 


# TODO:

• Implement configurable button.  
• Implement configurable window size.  
• Implement configurable starting button position.  
• Implement singleton design pattern.  
• Implement sockets(?)  
