#!/bin/bash

production() {
  ssh deploy@93.119.3.96
}

staging() {
  ssh deploy@149.210.238.137
}

"$@"

# bash ssh-to.sh production
# bash ssh-to.sh staging
