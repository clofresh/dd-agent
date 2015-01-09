require './ci/common'

namespace :ci do
  namespace :mongo do
    task :before_install => ['ci:common:before_install']

    task :install => ['ci:common:install'] do
      sh %Q{[ -e $HOME/downloads/mongodb-linux-x86_64-2.6.6.tgz ] || curl -s -L -o $HOME/downloads/mongodb-linux-x86_64-2.6.6.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.6.tgz}
      sh %Q{mkdir -p $HOME/mongo}
      sh %Q{tar zxf $HOME/downloads/mongodb-linux-x86_64-2.6.6.tgz -C $HOME/mongo/ --strip-components=1}
    end

    task :before_script => ['ci:common:before_script'] do
      sh %Q{mkdir -p /tmp/mongod1}
      sh %Q{mkdir -p /tmp/mongod2}
      hostname = `hostname`.strip
      sh %Q{$HOME/mongo/bin/mongod --port 37017 --dbpath /tmp/mongod1 --replSet rs0/#{hostname}:37018 --logpath /tmp/mongod1/mongo.log --noprealloc --rest --fork}
      sh %Q{$HOME/mongo/bin/mongod --port 37018 --dbpath /tmp/mongod2 --replSet rs0/#{hostname}:37017 --logpath /tmp/mongod2/mongo.log --noprealloc --rest --fork}

      # Set up the replica set + print some debug info
      sleep_for(15)
      sh %Q{$HOME/mongo/bin/mongo --eval "printjson(db.serverStatus())" 'localhost:37017' >> /tmp/mongo.log}
      sh %Q{$HOME/mongo/bin/mongo --eval "printjson(db.serverStatus())" 'localhost:37018' >> /tmp/mongo.log}
      sh %Q{$HOME/mongo/bin/mongo --eval "printjson(rs.initiate()); printjson(rs.conf());" 'localhost:37017' >> /tmp/mongo.log}
      sleep_for(30)
      sh %Q{$HOME/mongo/bin/mongo --verbose --eval "printjson(rs.config()); printjson(rs.status());" 'localhost:37017' >> /tmp/mongo.log}
      sh %Q{$HOME/mongo/bin/mongo --verbose --eval "printjson(rs.config()); printjson(rs.status());" 'localhost:37018' >> /tmp/mongo.log}
    end

    task :script => ['ci:common:script'] do
      this_provides = [
        'mongo',
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task :execute => [:before_install, :install, :before_script, :script]
  end
end
