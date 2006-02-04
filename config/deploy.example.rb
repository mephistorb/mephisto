# This defines a deployment "recipe" that you can feed to switchtower
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "mephisto"
set :repository, "http://techno-weenie.net/svn/projects/mephisto"

# =============================================================================
# RAILS VERSION
# =============================================================================
# Use this to freeze your deployment to a specific rails version.  Uses the rake
# init task run in after_symlink below.

set :rails_version, 3517

# TODO: test this works and I can remove the restart task and use the cleanup task
# set :use_sudo, false

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "www01.example.com", "www02.example.com"
role :app, "app01.example.com", "app02.example.com", "app03.example.com"
role :db,  "db01.example.com", :primary => true
role :db,  "db02.example.com", "db03.example.com"

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
# set :deploy_to, "/path/to/app" # defaults to "/u/apps/#{application}"
# set :user, "flippy"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

# no sudo access on txd :)
desc "Restart the FCGI processes on the app server."
task :restart, :roles => :app do
  run "ruby #{current_path}/script/process/reaper -d #{deploy_to}/current/public/dispatch.fcgi"
end

desc "Checks out rails rev ##{rails_version}"
task :after_symlink do
  run <<-CMD
    cd #{current_release} &&
    rake init REVISION=#{rails_version} RAILS_PATH=/home/technoweenie/projects/rails
  CMD
end