require './ci/common'

namespace :ci do
  namespace :cassandra do
    task :before_install => ['ci:common:before_install']

    task :install => ['ci:common:install'] do
      sh %Q{[ -e $HOME/downloads/apache-cassandra-2.1.1-bin.tar.gz || curl -s -L -o $HOME/downloads/apache-cassandra-2.1.1-bin.tar.gz http://apache.petsads.us/cassandra/2.1.1/apache-cassandra-2.1.1-bin.tar.gz}
      sh %Q{mkdir -p $HOME/cassandra}
      sh %Q{tar zxf $HOME/downloads/apache-cassandra-2.1.1-bin.tar.gz -C $HOME/cassandra/ --strip-components=1}
    end

    task :before_script => ['ci:common:before_script'] do
      sh %Q{$HOME/cassandra/bin/cassandra}
      # Wait for cassandra to init
      sleep_for 10
    end

    task :script => ['ci:common:script'] do
      this_provides = [
        'cassandra',
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task :execute => [:before_install, :install, :before_script, :script]
  end
end
