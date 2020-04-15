#!/bin/bash

production() {
  ssh deploy@149.210.229.119
}

staging() {
  ssh deploy@134.209.90.215
}

"$@"

# bash ssh-to.sh production
# bash ssh-to.sh staging
