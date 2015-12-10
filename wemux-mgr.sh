#!/usr/bin/env bash
set -e
[ -n "$DEBUG" ] && set -x
CWD=$(dirname $(readlink -f $0)); pushd ${CWD} >/dev/null

function usage() {
  >&2 echo "
Usage: $(basename $0) CONTAINER COMMAND

With:
  CONTAINER: the name or id of the container

  COMMAND:
    adduser|u USER [SSH_PUBIC_KEY_PATH]
      Add a user in the Docker container in mirror mode

    addkey|k USER SSH_PUBLIC_KEY_PATH
      Add a SSH_PUBIC_KEY_PATH into the authorized_keys
      file of the USER 

    setmode|m USER MODE
      Set the wemux mode for the user (mirror, pair, rogue)
"
}

# Main functions
function add_user() {
  local container="$1"
  local user="$2"
  local key_path="$3"

  check_requirements "bash"

  docker exec $container adduser -D -h /home/$user -s /bin/bash $user
  docker exec $container passwd -u $user # Unlock the user

  set_wemux_mode "$container" "$user" "mirror"

  if [ -n "$key_path" ]; then
    add_ssh_key "$container" "$user" "$key_path"
  fi
}

function add_ssh_key() {
  local container="$1"
  local user="$2"
  local key_path="$3"
  
  local ssh_dir="/home/$user/.ssh"
  local authorized_keys="$ssh_dir/authorized_keys"

  check_user_exists $container $user

  docker exec $container mkdir -p $ssh_dir
  cat_file $key_path | docker exec -i $container sh -c "cat >> $authorized_keys"
  docker exec $container chown -R $user:$user $ssh_dir
  docker exec $container chmod -R 700 $ssh_dir
  docker exec $container chmod -R 640 $authorized_keys
}

function set_wemux_mode() {
  local container="$1"
  local user="$2"
  local mode="$3"
 
  local supported_mode="mirror pair rogue" # Mode that can be set

  check_user_exists $container $user

  if [ ! "${supported_mode#$mode}" == "${supported_mode}" ]; then
    echo "wemux $mode; exit" | docker exec -i $container sh -c "cat > /home/$user/.bash_profile" 
  else
    message "error" "Wemux mode $mode unsupported. Please choose a mode in '${supported_mode}'"
  fi
}

function main() {
  local container="$1"
  local cmd="$2"
  [ $# -ge 2 ] && shift 2

  try_import_shml "1.0.3"

  case $cmd in
    adduser|u)
      local user="$1"
      local key_path="$2"
      add_user "$container" "$user" "$key_path";;
    addkey|k)
      local user="$1"
      local key_path="$2"
      add_ssh_key "$container" "$user" "$key_path";;
    setmode|m)
      local user="$1"
      local mode="$2"
      set_wemux_mode "$container" "$user" "$mode";;
    --help|-h|*)
      usage
      message "error" "Unknown command '$cmd'";;
  esac
}

# Libraries
function check_user_exists() {
  local container="$1"
  local user="$2"

  docker exec $container id $user
}

function check_requirements() {
  local requirements="$1"

  for tool in $requirements; do
    which $tool >/dev/null
  done
}

# Print the content of a local file or hosted on a web server
function cat_file() {
  local file_path="$1"

  case $file_path in
    http://*|https://*) curl $file_path;;
    *) cat $file_path;;
  esac
}

function try_import_shml() {
  shml_version="$1"
  shml_url="https://raw.githubusercontent.com/MaxCDN/shml/${shml_version}/shml.sh"

  shml_filename="$(basename $shml_url)" # Name of the file to import

  wget --quiet --no-clobber $shml_url | true
  [ -f $shml_filename ] && source $shml_filename
}

function message() {
  local msg_type="$1"
  local msg="$2"

  case $msg_type in
    info)  printf "$(fgcolor green)--> $msg$(fgcolor end)\n";;
    error) printf "$(fgcolor red)Error: $msg$(fgcolor end)\n"; exit 1;;
    *) printf "$(fgcolor yellow)Unknown message type $msg_type$(fgcolor end)\n";;
  esac
}

main "$@"
