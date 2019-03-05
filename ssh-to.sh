#!/bin/bash

production() {
  ssh deploy@178.62.231.57
}

staging() {
  ssh deploy@134.209.90.215
}

"$@"

# bash ssh-to.sh production
# bash ssh-to.sh staging
