require './ci/common'

namespace :ci do
  namespace :elasticsearch do
    task :before_install => ['ci:common:before_install']

    task :install => ['ci:common:install'] do
      sh %Q{[ -e $HOME/downloads/elasticsearch-1.4.2.tar.gz ] || curl -s -L -o $HOME/downloads/elasticsearch-1.4.2.tar.gz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.tar.gz}
      sh %Q{mkdir -p $HOME/elasticsearch}
      sh %Q{tar zxf $HOME/downloads/elasticsearch-1.4.2.tar.gz -C $HOME/elasticsearch/ --strip-components=1}
    end

    task :before_script => ['ci:common:before_script'] do
      sh %Q{$HOME/elasticsearch/bin/elasticsearch -d}
      sleep_for 10
    end

    task :script => ['ci:common:script'] do
      this_provides = [
        'elasticsearch',
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task :execute => [:before_install, :install, :before_script, :script]
  end
end
