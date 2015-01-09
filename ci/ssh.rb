require './ci/common'

namespace :ci do
  namespace :ssh do
    task :before_install => ['ci:common:before_install'] do
    end

    task :install => ['ci:common:install'] do
    end

    task :before_script => ['ci:common:before_script'] do
      # Create test/test account
      sh %Q{sudo useradd -m -p $(perl -e 'print crypt("test", "password")') test}
    end

    task :script => ['ci:common:script'] do
      this_provides = [
        'ssh',
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task :execute => [:before_install, :install, :before_script, :script]
  end
end
