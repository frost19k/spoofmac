#!/usr/bin/env bash

nullout='> /dev/null 2>&1'

reset='\033[0m'
red='\033[0;31m'
b_red='\033[1;31m'
green='\033[0;32m'
purple='\033[0;35m'

function print_banner() {
    echo -e "${purple}____ ___  ____ ____ ____ _  _ ____ ____${reset}"
    echo -e "${purple}[__  |__] |  | |  | |___ |\/| |__| |   ${reset}"
    echo -e "${purple}___] |    |__| |__| |    |  | |  | |___${reset}"
    echo ''
}

function log_crt() {
  local message=$1
  printf "$(date +'%H:%M:%S') ⋞ 💥 ⋟ ${b_red}${message} (${BASH_SOURCE[$i]##*/}:${BASH_LINENO[$i+1]}) \b${reset}\n" >&2
  exit 1
}

function log_info() {
  [[ $1 == '-p' ]] && { message=$2 && newline=''; } || { message=$1 && newline='\n'; }
  [[ $1 == '-d' ]] && { printf "[${green}Done${reset}]\n"; return; }
  [[ $1 == '-e' ]] && { printf "[${red}Error${reset}]\n"; return; }
  printf "$(date +'%H:%M:%S') ⋞ 💬 ⋟ ${message} \b${reset}${newline}"
}

print_banner
eval cd -- "${0%/*}" >/dev/null 2>&1

[[ ${EUID} != 0 ]] && log_crt "This script needs to run as root."
( ! command -v jq &>/dev/null ) && log_crt "Dependency 'jq' not found."
( ! command -v lshw &>/dev/null ) && log_crt "Dependency 'lshw' not found."

idxfile='src/meta.json'
[[ ! -f ${idxfile} ]] && log_crt "Someting went wrong... Run 'git pull' and try again."

log_info -p "Installing files..."
eval mkdir -p /usr/local/lib/systemd/system ${nullout}
eval cp -f "$(jq -r '.[].script.src' ${idxfile})" "$(jq -r '.[].script.dst' ${idxfile})" ${nullout}
eval cp -f "$(jq -r '.[].service.src' ${idxfile})" "$(jq -r '.[].service.dst' ${idxfile})" ${nullout}
log_info -d

log_info -p "Enabling service..."
eval chmod +x "$(jq -r '.[].script.dst' ${idxfile})" ${nullout}
eval chown root:root "$(jq -r '.[].script.dst' ${idxfile})" "$(jq -r '.[].service.dst' ${idxfile})" ${nullout}
eval systemctl enable spoofmac.service ${nullout}
log_info -d

log_info "All done!"
log_info "Restart your computer to apply the changes 🙂"

exit 0