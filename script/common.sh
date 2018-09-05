#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() {
    printf "$GREEN[$(date +"%F %T,%3N")] $1$NC\n"
}

log_error() {
    printf "$RED[$(date +"%F %T,%3N")] $1$NC\n"
}

check_require() {
    if [[ -z ${2//[[:blank:]]/} ]]; then
        log_error "$1 is required"
        exit 1
    fi
}

update_conf(){
     log_info "setting value for $1"
     defaults write sogod "$1" "$2"
}