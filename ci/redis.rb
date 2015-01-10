require './ci/common'

namespace :ci do
  namespace :cache do
    task :before_install => ['ci:common:before_install']

    task :install => ['ci:common:install'] do
      # don't cache it, it follows the bugfixes e.g. 2.8.x
      redis_version = '2.8'
      sh %Q{curl -s -L -o /tmp/redis.zip https://github.com/antirez/redis/archive/#{redis_version}.zip}
      sh %Q{mkdir -p $HOME/redis}
      sh %Q{unzip -x /tmp/redis.zip -d $HOME/}
      sh %Q{cd $HOME/redis-#{redis_version} && make}
    end

    task :before_script => ['ci:common:before_script'] do
      # Run redis !
      redis_version = '2.8'
      sh %Q{$HOME/redis-#{redis_version}/src/redis-server $TRAVIS_BUILD_DIR/tests/integrations_config/redis/auth.conf}
      sh %Q{$HOME/redis-#{redis_version}/src/redis-server $TRAVIS_BUILD_DIR/tests/integrations_config/redis/noauth.conf}
    end

    task :script => ['ci:common:script'] do
      this_provides = [
        'redis',
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task :execute => [:before_install, :install, :before_script, :script]
  end
end
