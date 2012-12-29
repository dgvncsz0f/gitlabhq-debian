app_dir = "/var/www/gitlabhq"
worker_processes 2
working_directory app_dir

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

listen "#{app_dir}/tmp/sockets/gitlab.socket"
pid "#{app_dir}/tmp/pids/unicorn.pid"
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  defined?(Resque) and Resque.redis.client.disconnect

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = "#{server.config[:pid]}.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  ##
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to git:git
  uid, gid    = Process.euid, Process.egid
  user, group = "gitlab", "gitlab"
  target_uid  = Etc.getpwnam(user).uid
  target_gid  = Etc.getgrnam(group).gid
  worker.tmp.chown(target_uid, target_gid)
  if uid != target_uid || gid != target_gid
    Process.initgroups(user, target_gid)
    Process::GID.change_privilege(target_gid)
    Process::UID.change_privilege(target_uid)
  end
end
