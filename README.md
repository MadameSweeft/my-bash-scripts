This is my bash script that helps to make using arduino-app-cli easier. 
I've only just started bash scripting so it isn't very elegant but it works.

I've updated the script because arduino-app-cli app list has changed to default to displaying only the user apps.
You need to use the flag -a, --all to list user apps, example apps and apps installed from a release.
Use --examples: Only list the example apps.

It also allows for arduino-app-cli app ps which lists the apps that have been initialized at least once, and their live status.
By default, only starting, running, stopping and failed apps are shown. Use -a or --all to also include stopped apps. 
Apps that have never been started are never shown; use 'app list' to browse the full catalog instead.
