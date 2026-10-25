#!/bin/bash

# This script provides a very simple menu in case you can't remember the commands
# It can also be run with:-
# --format string     Output format (text/json) (default "text")
# --log-level string  Set the log level (debug/info/warn/error) (default "error")
# No validation on this!!
globals=$@
echo $globals

#user_pref="user:"
#example_pref="example:"
#brick_pref="arduino:"
#model_pref="???"
user_pref="/var/"
example_pref="/var/"
brick_pref="/var/"
model_pref="/var/"
app_exist=true

# START OF CHECK TO SEE IF APP EXISTS
get_app_path() {

while true
# do this outside
# ask if user or example
 # app_pref=user_pref
 # app_pref=example_pref
  do
    read -p "Enter app name: " app_name
    app_path=$app_pref$app_name
    if [ -z $app_name ]; then
      continue   
    elif [ -d $app_path ]; then
      echo "$app_path exists"
    else
      echo "$app_path does not exist"
    fi
  break  
  done
}
# END OF CHECK TO SEE IF APP EXISTS

# START OF CHECK TO SEE IF BRICK EXISTS
get_brickpath() {

while true
  do
    read -p "Enter brick name: " brickname
    brickpath=$brick_pref$brickname
    if [ -d $brickpath ] || [ -z $brickname ]; then
      break
    else
      echo "Invalid brickname '$brickname'. Try again."
    fi  
  done
}
# END OF CHECK TO SEE IF BRICK EXISTS

# START OF CHECK TO SEE IF MODEL EXISTS
get_modelpath() {

while true
  do
    read -p "Enter model name: " modelname
    modelpath=$model_pref$modelname
    if [ -d $modelpath ] || [ -z $modelname ]; then
      break
    else
      echo "Invalid modelname '$modelname'. Try again."
    fi  
  done
}
# END OF CHECK TO SEE IF MODEL EXISTS

# START OF APP COMMAND
app_menu() {
  get_app_path

  PS3="Select a sub command: "
  app_cmds=("clean-cache" "destroy" "export"
  	"import" "list" "logs" "new" "restart"
  	"start" "stop" "back" )

  select app_cmd in "${app_cmds[@]}"
  do
    case $app_cmd in
      ${app_cmds[0]})  # clean-cache
        # add app_id and ask about force
	app_id=1234
        exec ./arduino-app-cli app clean-cache $app_id --force;;

      ${app_cmds[1]})  # destroy
	app_path=user/q1234
        exec ./arduino-app-cli app destroy $app_path;;

      ${app_cmds[2]})  # export
        # ask about --include-data and --overwrite
	app_path=user/q1234
	out_path=c:\user\charl
        incl="--include-data"
        over="--overwrite"
        exec ./arduino-app-cli app export $app_path $out_path $incl $over;;

      ${app_cmds[3]})  # import
        zip_path=c:\dsdsdsa 
        # or "-" for stdin
        exec ./arduino-app-cli app import $zip_path;;

      ${app_cmds[4]})  # list
        echo -n "Show broken apps? (Y)es/(N)o [N] "
	read answer
	case $answer in
	y|Y)
          exec ./arduino-app-cli app list --show-broken-apps;;
	*)
          exec ./arduino-app-cli app list;;
 	esac;;

      ${app_cmds[5]})  # logs
        all="--all" 
        follow="--follow"
        tail="--tail"
	app_path=user/q1234
        exec ./arduino-app-cli app logs $app_path $all $follow $tail;;

      ${app_cmds[6]})  # new
        app_pref=$user_pref
        get_app_path # until it doesn't exist
# ask if copying from example/user or none
#copy:-        app_pref=$user_pref $example_pref
#        get_app_path # until it's found
# use --from-app
        # ask for name and check if it already exists
        # ask about --bricks --description and --tail
        # and --from-app (example/user) and check if it exists
        # and --icon --no-sketch

      ${app_cmds[7]})  # restart
	app_path=user/q1234
        exec ./arduino-app-cli app restart $app_path;;

     ${app_cmds[8]})  # start
	app_path=user/q1234
        exec ./arduino-app-cli app start $app_path;;

      ${app_cmds[9]})  # stop
	app_path=user/q1234
        exec ./arduino-app-cli app stop $app_path;;

      ${app_cmds[10]})  # back
        echo "Press 'enter' to redisplay main menu: "
        PS3="Select a command: "
        break;;
      *)
        echo "Invalid command. Try again";;
    esac
  done
}
# END OF APP COMMAND

# START OF SYSTEM COMMAND
system_menu() {

  PS3="Select a sub command: "
  sys_cmds=("cleanup" "keyboard" "network-mode"
  	       "set-name" "update" "back")

  select sys_cmd in "${sys_cmds[@]}"
  do
    case $sys_cmd in
      ${sys_cmds[0]})  # cleanup
        exec ./arduino-app-cli system cleanup;;
 
      ${sys_cmds[1]})  # keyboard
        # choose layout
        layout="UK"
        exec ./arduino-app-cli system keyboard $layout;;

      ${sys_cmds[2]})  # network-mode
        # choose enable disable or status
        mode="enable"
        exec ./arduino-app-cli system network-mode $mode;;

     ${sys_cmds[3]})  # set-name
       read -p "Enter new name: " qname
       if [ -z $qname ]; then
         echo "Name not changed"
         echo "Press 'enter' to redisplay main menu: "
         PS3="Select a command: "
         break   
       else
         exec ./arduino-app-cli system set-name $qname
       fi;;

      ${sys_cmds[4]})  # update
        echo -n "Only update Arduino specific packages? (Y)es/(N)o [N] "
	read answer
	case $answer in
	y|Y)
          only="--only-arduino";;
	*)
          only="";;
 	esac

        echo -n "Automatically confirm all prompts? (Y)es/(N)o [N] "
	read answer
	case $answer in
	y|Y)
          exec ./arduino-app-cli system update $only --yes;;
	*)
          exec ./arduino-app-cli system update $only;;
 	esac;;

      ${sys_cmds[5]})  # back
        echo "Press 'enter' to redisplay main menu: "
        PS3="Select a command: "
        break;;

      *)
        echo "Invalid sub command. Try again";;
    esac
  done
}
# END OF SYSTEM COMMAND

# START OF MAIN SCRIPT
PS3="Select a command: "

commands=("app" "brick" "completion" "config" "daemon" "model"
          "monitor" "properties" "system" "version" "quit" )
select command in "${commands[@]}"
do
  case $command in
    ${commands[0]})  # app
      app_menu;;

    ${commands[1]})  # brick
      while true
      do
        echo -n "(L)ist or(D)etails? [L] "
        read answer
        case $answer in
	  d|D)
            get_brickpath
            if ! [ -z $brickname ]; then
              exec ./arduino-app-cli brick details $brickpath
            fi;;
 	  *)
            exec ./arduino-app-cli brick list $globals;;
        esac
       done;;

    ${commands[2]})  # completion
      echo -n "Which shell? (b)ash (z)sh (f)ish (p)owershell [b] "
      read answer
      case $answer in
	z|Z)
          shell="zsh";;
	f|F)
          shell="fish";;
	p|P)
          shell="powershell";;
	*)
          shell="bash";;
      esac
       
      echo -n "Show descriptions? (Y)es/(N)o [Y] "
      read answer
      case $answer in
        n|N)
          exec ./arduino-app-cli completion $shell --no-descriptions;;
	*)
          exec ./arduino-app-cli completion $shell;;
	esac;;

    ${commands[3]})  # config
      exec ./arduino-app-cli config get;; 

    ${commands[4]})  # daemon
      read -p "Enter port (or 'enter' for default): " port_no
      if [ -z $port_no ]; then
        exec ./arduino-app-cli daemon 
      else
        exec ./arduino-app-cli daemon --port $port_no
      fi;;  

    ${commands[5]})  # model
     while true
      do
        echo -n "(L)ist or(D)elete? [L] "
        read answer
        case $answer in
	  d|D)
            get_modelpath
            echo -n "Delete model in use? (Y)es/(N)o [N] "
            read answer
            case $answer in
              y|Y)
                exec ./arduino-app-cli model delete $model_name --force;;
	      *)
                exec ./arduino-app-cli model delete $model_name;;
	    esac;;
 	  *)
            exec ./arduino-app-cli model list;;
        esac
      done;;

    ${commands[6]}) # monitor
      exec ./arduino-app-cli monitor;; 

    ${commands[7]})  # properties
      while true
      do
        echo -n "(G)et or(S)et? [G] "
        read answer
        case $answer in
	  g|G)
            exec ./arduino-app-cli properties get default;;
	  s|S)
            get_app_path
            exec ./arduino-app-cli properties set default $app_path;;
 	  *)
            echo "Invalid Sub Command. Try again";;
        esac
       done;;

    ${commands[8]})  # system
      system_menu;;

    ${commands[9]})  # version
      # --port string The daemon network port (default "8800")
      port="--port 8800" # or ""
      exec ./arduino-app-cli version $port $globals;;

    ${commands[10]})  # quit
      echo "Quitting"
      break;;
    *)
      echo "Invalid Command. Try again";;
  esac
done

# END OF MAIN SCRIPT
