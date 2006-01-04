# =============================================================================
# A set of rake tasks for invoking the SwitchTower automation utility.
# =============================================================================

desc "Push the latest revision into production using the release manager"
task :deploy do
  system "switchtower -vvvv -r config/deploy -a deploy"
end

desc "Rollback to the release before the current release in production"
task :rollback do
  system "switchtower -vvvv -r config/deploy -a rollback"
end

desc "Describe the differences between HEAD and the last production release"
task :diff_from_last_deploy do
  system "switchtower -vvvv -r config/deploy -a diff_from_last_deploy"
end

desc "Enumerate all available deployment tasks"
task :show_deploy_tasks do
  system "switchtower -r config/deploy -a show_tasks"
end

desc "Execute a specific action using the release manager"
task :remote_exec do
  unless ENV['ACTION']
    raise "Please specify an action (or comma separated list of actions) via the ACTION environment variable"
  end

  actions = ENV['ACTION'].split(",").map { |a| "-a #{a}" }.join(" ")
  system "switchtower -vvvv -r config/deploy #{actions}"
end
