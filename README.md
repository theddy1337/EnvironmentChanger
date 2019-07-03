Environment Selector 1.0
================
# About

Pretty basic tool to help with the testers to swap environments really quickly without having to download a specific build.
Displays a button in the top right corner that when selected,
drops down the menu with the given possible backend environments that the user can select.

# Usage 

Select the button and an alert with the given environments will show up,
select the environment that you would like to use and simply restart the app.
Also, you can drag the button across the screen. Position it as you wish.

# Developer implementation
 
let envChanger = EnvironmentChangerController(envs: Envs.self) { selectedEnvironment in
ServerManager.sharedInstance.requestAppLogout()
}

ACTIVE_ENVIRONMENT = envChanger.getSavedEnvironment()
