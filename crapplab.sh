
#!/bin/bash

# This script provides a very simple menu in case you can't remember the commands
# It can also be run with:-
# --format string     Output format (text/json) (default "text")
# --log-level string  Set the log level (debug/info/warn/error) (default "error")

# I've also added the ability to add a requirements file when creating a new app
# This isn't actually included in arduino-app-cli but I find it quite useful.

# No validation on this!! GIGO
globals=$@
echo $globals

shopt -s expand_aliases

# START OF APP COMMAND
app_menu() {

  PS3="Select a sub command: "
  app_cmds=("clean-cache" "destroy" "export"
  	"import" "list" "logs" "new" "restart"
  	"start" "stop" "back" )

  select app_cmd in "${app_cmds[@]}"
  do
    case $app_cmd in
      ${app_cmds[0]})  # clean-cache
	read -p "Enter app name: " app_id
        echo -n "Force clean-cache? (Y)es/(N)o [N] "
        read answer
        case $answer in
          y|Y)
            exec arduino-app-cli app clean-cache $app_id --force;;
          *)
            exec arduino-app-cli app clean-cache $app_id;;
        esac;;
      ${app_cmds[1]})  # destroy
	read -p "Enter app name: " app_path
        exec arduino-app-cli app destroy $app_path;;

      ${app_cmds[2]})  # export
	read -p "Enter app name: " app_path
	read -p "Enter out path: " out_path
        echo -n "Include data? (Y)es/(N)o [N] "
        read answer
        case $answer in
          y|Y)
            incl="--include-data";;
          *)
             incl="";;
        esac
        echo -n "Overwrite? (Y)es/(N)o [N] "
        read answer
        case $answer in
          y|Y)
            exec arduino-app-cli app export $app_path $out_path $incl "--overwrite";;
          *)
            exec arduino-app-cli app export $app_path $out_path $incl;;
        esac;;

      ${app_cmds[3]})  # import
	read -p "Enter zip path (or - for stdin): "  zip_path 
        exec arduino-app-cli app import $zip_path;;

      ${app_cmds[4]})  # list
        echo -n "Show broken apps? (Y)es/(N)o [N] "
	read answer
	case $answer in
	y|Y)
          exec arduino-app-cli app list --show-broken-apps;;
	*)
          exec arduino-app-cli app list;;
 	esac;;

      ${app_cmds[5]})  # logs
	read -p "Enter app name: " app_path
        echo -n "All? (Y)es/(N)o [N] "
        read answer
        case $answer in
          y|Y)
            all="--all" ;;
          *)
            all="";;
        esac 
        echo -n "Follow? (Y)es/(N)o [N] "
        read answer
        case $answer in
          y|Y)
            follow="--follow";;
          *)
            follow="";;
        esac
        echo -n "Tail? (Y)es/(N)o [N] "
        read answer
        case $answer in
          y|Y)
            read -p "How many? ('enter' for default of 100): " tail_no
            if [ -z $tail_no ]; then
              tail_no=100
            fi
            tail="--tail $tail_no";;
          *)
            tail="";;
        esac
        exec arduino-app-cli app logs $app_path $all $follow $tail;;

      ${app_cmds[6]})  # new
	read -p "Enter new app name: " app_name
	read -p "Copy from app? (app name or 'enter' for no): " from_app
        if ! [ -z $from_app ]; then
          exec arduino-app-cli app new $app_name --from-app $from_app
        fi
	echo "Bricks? (brick list or 'enter' for no): "
	read -a brick_list
        if ! [ -z $brick_list ]; then
          # -b does_not_work
          real_brick_list=""
          for i in "${brick_list[@]}"
          do
            real_brick_list="$real_brick_list\n  - $i"
          done
          echo $real_brick_list
        fi
	echo "Requirements? (package list or 'enter' for no): "
	read -a package_list
    # for some strange reason, the following  lines keep getting indented
    echo "Add description? (description or 'enter' for no): "
    read -a descrip
        if ! [ -z $descrip ]; then
          repl_str="replace_this"
          desc_req="-d $repl_str"
          real_desc="${descrip[@]}"
        fi
	read -p "Add icon? (paste icon or 'enter' for no): " icon
        if ! [ -z $icon ]; then
          icon_req="-i $icon"
        fi
        echo -n "Sketch? (Y)es/(N)o [Y] "
	read answer
        case $answer in
          n|N)
            arduino-app-cli app new $app_name $bricks $desc_req $icon_req --no-sketch;;
          *)
            arduino-app-cli app new $app_name $bricks $desc_req $icon_req;;
        esac
        if ! [ -z $descrip ]; then
          sed -i -e "s/$repl_str/$real_desc/g" ~/ArduinoApps/$app_name/README.md
        fi
        if ! [ -z $brick_list ]; then
          sed -i 's/ks: [][]/ks:/g' ~/ArduinoApps/$app_name/app.yaml
          sed -i -e "s/ks:]/ks:$real_brick_list/g" ~/ArduinoApps/$app_name/app.yaml
        fi

        if ! [ -z $package_list ]; then
          for i in "${package_list[@]}"
          do
          echo $i >> ~/ArduinoApps/$app_name/python/requirements.txt
          done
        fi

        exit 1;;  # this is here because I didn't use exec for creating a new app
      ${app_cmds[7]})  # restart
	read -p "Enter app name: " app_path
        echo -n "Verbose? (Y)es/(N)o [N] "
        read  answer
        case $answer in
          y|Y)
            exec arduino-app-cli app restart $app_path "-v";;
          *)
            exec arduino-app-cli app restart $app_path;;
        esac;;
     ${app_cmds[8]})  # start
	read -p "Enter app name: " app_path
        echo -n "Verbose? (Y)es/(N)o [N] "
        read  answer
        case $answer in
           y|Y)
             exec arduino-app-cli app start $app_path "-v";;
           *)
             exec arduino-app-cli app start $app_path;;
        esac;;
      ${app_cmds[9]})  # stop
	read -p "Enter app name: " app_path
        exec arduino-app-cli app stop $app_path;;

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
        exec arduino-app-cli system cleanup;;
 
      ${sys_cmds[1]})  # keyboard
        # choose layout
        layout="UK"
        exec arduino-app-cli system keyboard $layout;;

      ${sys_cmds[2]})  # network-mode
        # choose enable disable or status
        mode="enable"
        exec arduino-app-cli system network-mode $mode;;

     ${sys_cmds[3]})  # set-name
       read -p "Enter new name: " qname
       if [ -z $qname ]; then
         echo "Name not changed"
         echo "Press 'enter' to redisplay main menu: "
         PS3="Select a command: "
         break
       else
         exec arduino-app-cli system set-name $qname
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
          exec arduino-app-cli system update $only --yes;;
	*)
          exec arduino-app-cli system update $only;;
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
      echo -n "(L)ist or(D)etails? [L] "
      read answer
      case $answer in
        d|D)
          read -p "Enter brick name: " brickpath
          exec arduino-app-cli brick details $brickpath;;
        *)
          exec arduino-app-cli brick list $globals;;
        esac;;

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
      read -p "Enter script filename: " scr_filename
      echo -n "Show descriptions? (Y)es/(N)o [Y] "
      read answer
      case $answer in
        n|N)
          exec arduino-app-cli completion $shell > $scr_filename --no-descriptions;;
	*)
          exec arduino-app-cli completion $shell > $scr_filename;;
	esac;;

    ${commands[3]})  # config
      exec arduino-app-cli config get;; 

    ${commands[4]})  # daemon
      read -p "Enter port (or 'enter' for default:8080): " port_no
      if [ -z $port_no ]; then
        exec arduino-app-cli daemon 
      else
        exec arduino-app-cli daemon --port $port_no
      fi;;  

    ${commands[5]})  # model
      echo -n "(L)ist or(D)elete? [L] "
      read answer
      case $answer in
        d|D)
          read -p "Enter model name: " model_name
          echo -n "Delete model in use? (Y)es/(N)o [N] "
          read answer
          case $answer in
            y|Y)
              exec arduino-app-cli model delete no$model_name --force;;
            *)
              exec arduino-app-cli model delete no$model_name;;
          esac;;
        *)
          exec arduino-app-cli model list;;
       esac;;

    ${commands[6]}) # monitor
      exec arduino-app-cli monitor;; 

    ${commands[7]})  # properties
      echo -n "(G)et or(S)et? [G] "
      read answer
      case $answer in
        s|S)
          read -p "Enter default app name (or Enter for No default app set): " app_path
          exec arduino-app-cli properties set default $app_path;;
        *)
          exec arduino-app-cli properties get default;;
       esac;;

    ${commands[8]})  # system
      system_menu;;

    ${commands[9]})  # version
      read -p "Enter port (or 'enter' for default:8800): " port_no
      if [ -z $port_no ]; then
        exec arduino-app-cli version $globals
      else
        exec arduino-app-cli version --port $port_no $globals
      fi;;
    ${commands[10]})  # quit
      echo "Quitting"
      break;;
    *)
      echo "Invalid Command. Try again";;
  esac
done

# END OF MAIN SCRIPT
