require './ci/common'

namespace :ci do
  namespace :sysstat do
    task :before_install => ['ci:common:before_install']

    task :install => ['ci:common:install'] do
      sh %Q{[ -e $HOME/downloads/sysstat-11.0.1.tar.xz ] || curl -s -L -o $HOME/downloads/sysstat-11.0.1.tar.xz http://perso.orange.fr/sebastien.godard/sysstat-11.0.1.tar.xz}
      sh %Q{mkdir -p $HOME/sysstat}
      sh %Q{tar Jxf $HOME/downloads/sysstat-11.0.1.tar.xz -C $HOME/sysstat/ --strip-components=1}
      sh %Q{mkdir -p $HOME/embedded}
      sh %Q{export PATH=$HOME/embedded/bin:$PATH}
      sh %Q{cd $HOME/sysstat && ./configure --prefix=$HOME/embedded/ && make && make install}
    end

    task :before_script => ['ci:common:before_script']

    task :script => ['ci:common:script'] do
      this_provides = [
        'sysstat',
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task :execute => [:before_install, :install, :before_script, :script]
  end
end
