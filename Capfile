# Load DSL and Setup Up Stages
require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rbenv'
require 'capistrano/puma'
require 'capistrano-db-tasks'

install_plugin Capistrano::Puma
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
