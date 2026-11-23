#!/bin/bash

BRICKDIR=~/CustomBricks/
APPPATH=~/ArduinoApps/

get_source_lib_brick_path() {
  echo
  if [ ! -d "$BRICKDIR" ]; then
    echo "Brick library $BRICKDIR does not exist"
    exit 1
  fi
  if [ ! "$(ls -A $BRICKDIR)" ]; then
    echo "No bricks found in brick library $BRICKDIR"
    exit 1
  fi
  ls $BRICKDIR
  echo
  read -p "Highlight the brick to copy and right click here twice: " source_brick
  source="$BRICKDIR$source_brick/"
}

get_source_app_brick_path() {
  echo
  if [ ! "$(ls -A $APPPATH)" ]; then
    echo "No user apps in $APPPATH"
    exit 1
  fi
  ls $APPPATH
  echo
  read -p "Highlight app to copy brick from and right click here twice: " source_app
  echo
  if [ ! -d "$APPPATH$source_app/bricks/" ]; then
    echo "No custom bricks in $source_app"
    exit 1
  fi
  if [ ! "$(ls -A $APPPATH$source_app/bricks/)" ]; then
    echo "No custom bricks in $source_app"
    exit 1
  fi
  ls "$APPPATH$source_app/bricks/"
  echo
  read -p "Highlight the brick to copy and right click here twice: " source_brick
  source="$APPPATH$source_app/bricks/$source_brick"
}

get_dest_app_brick_path() {
  echo
  if [ ! "$(ls -A $APPPATH)" ]; then
    echo "No user apps in $APPPATH"
    exit 1
  fi
  ls $APPPATH
  echo
  read -p "Highlight app to copy brick to and right click here twice: " dest_app
  dest="$APPPATH$dest_app/bricks/"
  if [ ! -d "$dest" ]; then
    mkdir $dest
  fi
  app_yaml="$APPPATH$dest_app/app.yaml"
}

add_custom_brick_to_yaml() {
  # First get rid of []. This takes 2 steps because sed doesn't like [] much
  sed -i 's/bricks: [][]/bricks:/g' $app_yaml
  sed -i -e "s/bricks:]/bricks:/g" $app_yaml
  # Now add the custom brick line
  sed -i -e "s/bricks:/bricks:\n- $source_brick: {}/g" $app_yaml
}

# Start of main script

echo -e "\nCustom Brick Copying\n"

if [ ! -d "$APPPATH" ]; then
  echo "Yikes!! $APPPATH doesn't exist."
  exit 1
fi

PS3="Choose option for copying brick: "

options=("App to App"
         "App to Brick library"
         "Brick library to App"
         "Copy Brick (using Brick library)"
         "Quit" )
select opt in "${options[@]}"
do
  case $opt in
     ${options[0]})  # copy custom brick from one app to another
       get_source_app_brick_path
       get_dest_app_brick_path
       echo
       if [ -d "$dest$source_brick" ]; then
         echo  "$source_brick is already in $dest_app"
         exit 1
       fi
       cp -r $source $dest
       add_custom_brick_to_yaml
       echo "$source copied to $dest"
       break;;
     ${options[1]})  # copy custom brick to brick library
       get_source_app_brick_path
       echo
       if [ -d "$BRICKDIR$source_brick" ]; then
         echo  "$source_brick is already in library"
         exit 1
       fi
       if [ ! -d "$BRICKDIR" ]; then
         mkdir  $BRICKDIR
       fi
       cp -r $source $BRICKDIR
       echo "$source copied to library"
       break;;
     ${options[2]})  # copy custom brick from library to app
       get_source_lib_brick_path
       get_dest_app_brick_path
       echo
       if [ -d "$dest$source_brick" ]; then
         echo  "$source_brick is already in $dest_app"
         exit 1
       fi
       cp -r $source $dest
       add_custom_brick_to_yaml
       echo "$source copied from library to $dest"
       break;;
     ${options[3]})  # copy brick to new brick (using library)
       get_source_lib_brick_path
       echo
       echo "Enter new brick name (lower/uppercase alphanumeric space): "
       read -a brick_temp
       if [ -z $brick_temp ]; then
         echo
         echo "No new brick name entered"
         exit 1
       fi
       brick_name="${brick_temp[@]}"
       brick_id=""
       filler=""
       for i in  "${brick_temp[@]}"
       do
         brick_id="$brick_id$filler$i"
         filler="_"
       done
       declare -l brick_id
       brick_id=$brick_id
       dest="$BRICKDIR$brick_id/"
       echo
       if [ -d "$BRICKDIR$brick_id" ]; then
         echo  "$brick_id is already in library"
         exit 1
       fi
       cp -a $source $dest
       # The next bit was difficult.
       # You can't just echo the id and name lines to the yaml file because there might be other lines in the file.
       # You could use sed to replace the old brick ID by the new brick ID but it's harder for the brick name as
       # you don't know what it was originally eg capitalisation.
       # To put a comment into the yaml file, you have to put something# and then delete the something.
       sed -i "s/id:/id: $brick_id ToTaLcRaP# Copied from/" $dest$dest_brick/brick_config.yaml
       sed -i "s/name:/name: $brick_name ToTaLcRaP# Copied from/" $dest$dest_brick/brick_config.yaml
       sed -i "s/ToTaLcRaP//g" $dest$dest_brick/brick_config.yaml
       echo   "$source copied to $dest in library"
       break;;
     ${options[4]})  # quitting
       echo "Quitting"
       break;;
     *)
       echo "Invalid option. Try again";;
   esac
done
