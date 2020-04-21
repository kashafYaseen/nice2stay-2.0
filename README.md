
## Contents

- [Setup Project Locally](#setup-project-locally)
- [Setup Production Server](#setup-production-server)
- [Useful production command](#useful-production-command)
- [Sidekiq helping material](#sidekiq-helping-material)
- [Useful capistrano commands](#useful-capistrano-commands)

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
  > [View Slite Private Document](https://devden.slite.com/api/s/note/Eu9YBik6wabjwTw4Caejdz/Environment-variables)
10. Start rails server
  ```sh
  rails s
  ```
11. Start webpacker server
  ```sh
  ruby bin/webpack-dev-server
  ```
## Setup Production Server
1. Login as root user and create new sudo user
  ```sh
  adduser deploy
  adduser deploy sudo
  exit
  ```
2. Install `ssh-copy-id` to local machine with brew and copy local ssh to production server.
  ```sh
  brew install ssh-copy-id
  ssh-copy-id root@149.210.229.119
  ssh-copy-id deploy@149.210.229.119
  ```
3. SSH in as deploy on production server
  ```sh
  ssh deploy@149.210.229.119
  ```
4. Install Ruby
  ```sh
  # Adding Node.js repository
  curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
  # Adding Yarn repository
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo add-apt-repository ppa:chris-lea/redis-server
  # Refresh our packages list with the new repositories
  sudo apt-get update
  # Install our dependencies for compiiling Ruby along with Node.js and Yarn
  sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev dirmngr gnupg apt-transport-https ca-certificates redis-server redis-tools nodejs yarn

  #Install Ruby with rbenv
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
  git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
  exec $SHELL
  rbenv install 2.5.0
  rbenv global 2.5.0
  ruby -v
  ```
5. Install bundler and rails
  ```sh
  gem install bundler -v 1.16.2
  bundle -v
  gem install rails -v '5.2.0'
  ```
6.  Create a PostgreSQL Database
  ```sh
  sudo apt-get install postgresql postgresql-contrib libpq-dev
  sudo su - postgres
  createuser --pwprompt deploy
  createdb -O deploy geosearch_production
  exit
  ```
7. Install elasticsearch
  ```sh
  # Download past release manually
  wget --no-check-certificate https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.7.2.deb
  # Install downloaded release
  sudo dpkg -i elasticsearch-6.7.2.deb
  # Start service
  sudo service elasticsearch start
  #Check service status
  sudo service elasticsearch status
  #Verify installed version details
  curl -XGET -u "elastic:passwordForElasticUser" 'localhost:9200'
  ```
8. Change IP if needed
  ```ruby
  # config/deploy/production.rb
  server 'replace-with-ip-address', port: 22, roles: [:web, :app, :db], primary: true
  ```
9. Deploy rails application from local machine
  ```sh
  # if deploying first time
  cap production deploy:initial
  # normal deployment
  cap production deploy
  ```
10. Copy environment varibales from [Slite](https://devden.slite.com/api/s/note/Eu9YBik6wabjwTw4Caejdz/Environment-variables) to `/etc/environment`

11. Configure Nginx
  - Remove default nginx configuration file
    `sudo rm /etc/nginx/sites-enabled/default`
  - create a new configuration file
    `touch /etc/nginx/sites-enabled/nice2stay`
  - Copy nginx configuration
    `cp /home/deploy/hidden-sun-3354/current/config/nginx-fe.conf /etc/nginx/sites-enabled/nice2stay`
   - Restart nginx server
     `sudo service nginx restart`
12. Install redis and sidekiq [LINK](https://thomasroest.com/2017/03/04/properly-setting-up-redis-and-sidekiq-in-production-ubuntu-16-04.html)

## Useful production command
1. Login to production server using ssh
  ```sh
  # using bash file
  bash ssh-to.sh production
  # or using ssh directly
  ssh deploy@nice2stay.com
  ```
2. View production logs
  ```sh
  # change directory
  cd hidden-sun-3354/current
  # tail logs
  tail -f log/production.log
  ```
3. Run rails console
  ```sh
  # change directory
  cd hidden-sun-3354/current
  # run console
  rails c -e production
  ```
4. Run rake task
  ```sh
  # change directory
  cd hidden-sun-3354/current
  bundle exec rake rake_task_name RAILS_ENV=production
  ```
## Sidekiq Helping Material
1. Sidekiq service [(view sudo passowrd)](https://devden.slite.com/api/s/note/BbmiM446BWXbvt2Z3V5HRY/Credentials)
  ```sh
  # restart service
  service sidekiq restart
  # check service status
  service sidekiq status
  ```
2. Edit service configuration [(view configuration file sample)](https://devden.slite.com/api/s/note/B5P6TwFBRht1TpEVuoqKcV/Sidekiq)
  ```sh
  sudo vim /lib/systemd/system/sidekiq.service
  ```
3. View sidekiq logs
  ```sh
  tail -f /home/deploy/hidden-sun-3354/current/log/sidekiq.log
  ```
## Useful Capistrano Commands
1. Deploy new release
  ```sh
  cap production deploy
  ```
2. Restart server
  ```sh
  cap production deploy:restart
  ```
3. Check puma status & restart
  ```sh
  # check puma status
  cap production puma:status
  # stop & start puma
  cap production puma:stop
  cap production puma:start
  ```
4. Pull production database locally
  ```sh
  cap production db:pull
  ```
