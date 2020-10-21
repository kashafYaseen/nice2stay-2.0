#!/bin/bash

production() {
  ssh deploy@149.210.229.119
}

staging() {
  ssh deploy@149.210.238.137
}

"$@"

# bash ssh-to.sh production
# bash ssh-to.sh staging
