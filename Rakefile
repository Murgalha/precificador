require 'filewatcher'

task :default => :dev

task :dev do
  pid = spawn_process
  Filewatcher.new(['src/', 'Rakefile', 'config.ru']).watch do |changes|
    Process.kill('SIGKILL', pid)
    Process.wait

    pid = spawn_process
  end
end

def spawn_process
  Process.spawn("bundle exec rackup -p 3000")
end
