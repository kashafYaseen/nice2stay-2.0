## Contents

- [Setup Project Locally](#setup-project-locally)

## Setup Project Locally
1. Clone Project
  ```sh
  git clone git@github.com:remcoz/search_es.git
  ```
2. Install ruby version 2.5.0
  ```sh
  rbenv install 2.5.0
  ruby -v
  ```
3. Install elasticsearch
  ```sh
  brew install elasticsearch
  brew services start elasticsearch
  ```
4. Install Gems
  ```sh
  bundle install
  ```
5. Upgrade to yarn 1.21.1 & install yarn packages
  ```sh
  yarn install
  ```
6. Setup database
  ```sh
  rails db:create
  rails db:migrate
  ```
7. Seed database with production db
  ```sh
  cap production db:pull
  ```
8. Reindex all searchkick models
  ```sh
  rake searchkick:reindex:all
  ```
9. Copy environment variables to .env file
  [View Slite Private Document](https://devden.slite.com/api/s/note/Eu9YBik6wabjwTw4Caejdz/Environment-variables)
10. Start rails server
  ```sh
  rails s
  ```
11. Start webpacker server
  ```sh
  ruby bin/webpack-dev-server
  ```
