require 'spec_helper'

describe "gitlab::gems" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::gems") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gems")
      end

      it "gets the latest certificate bundle" do
        expect(chef_run).to create_remote_file_if_missing("Fetch the latest ca-bundle").with(owner: "git", group: "git", source: "http://curl.haxx.se/ca/cacert.pem", path: "/opt/local/etc/certs/cacert.pem")
      end

      it 'creates a gemrc from template' do
        expect(chef_run).to create_template_if_missing('/home/git/.gemrc').with(
          source: "gemrc.erb",
          user: "git",
          group: "git",
        )
      end

      it 'does not run a execute to bundle install on its own' do
        expect(chef_run).to run_execute('bundle install')
      end

      describe "creating gemrc" do
        let(:template) { chef_run.template('/home/git/.gemrc') }

        it 'executes bundle without development and test' do
          resource = chef_run.find_resource(:execute, 'bundle install')
          expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without postgres aws development test\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        describe "for development" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
            runner.node.set['gitlab']['env'] = "development"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without production' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without postgres aws production\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end

        describe "when using mysql" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "mysql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['mysql']['server_root_password'] = "rootpass"
            runner.node.set['mysql']['server_repl_password'] = "replpass"
            runner.node.set['mysql']['server_debian_password'] = "debpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without postgres' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without postgres aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end

        describe "when using postgres" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "postgresql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without mysql' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without mysql aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end
      end
    end
  end

    describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gems")
      end

      it "gets the latest certificate bundle" do
        expect(chef_run).to create_remote_file_if_missing("Fetch the latest ca-bundle").with(owner: "git", group: "git", source: "http://curl.haxx.se/ca/cacert.pem", path: "/opt/local/etc/certs/cacert.pem")
      end

      it 'creates a gemrc from template' do
        expect(chef_run).to create_template_if_missing('/home/git/.gemrc').with(
          source: "gemrc.erb",
          user: "git",
          group: "git",
        )
      end

      it 'does not run a execute to bundle install on its own' do
        expect(chef_run).to run_execute('bundle install')
      end

      describe "creating gemrc" do
        let(:template) { chef_run.template('/home/git/.gemrc') }

        it 'executes bundle without development and test' do
          resource = chef_run.find_resource(:execute, 'bundle install')
          expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without postgres aws development test\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        describe "for development" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "centos", version: version)
            runner.node.set['gitlab']['env'] = "development"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without production' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without postgres aws production\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end

        describe "when using mysql" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "centos", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "mysql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['mysql']['server_root_password'] = "rootpass"
            runner.node.set['mysql']['server_repl_password'] = "replpass"
            runner.node.set['mysql']['server_debian_password'] = "debpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without postgres' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without postgres aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end

        describe "when using postgres" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "centos", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "postgresql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without mysql' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment --without mysql aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end
      end
    end
  end
end
