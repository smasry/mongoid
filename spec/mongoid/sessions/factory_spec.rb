require "spec_helper"

describe Mongoid::Sessions::Factory do

  describe ".create" do

    context "when provided a name" do

      context "when the configuration exists" do

        context "when the configuration is standard" do

          let(:config) do
            {
              default: { hosts: [ "localhost:27017" ], database: database_id },
              secondary: { hosts: [ "localhost:27017" ], database: database_id }
            }
          end

          before do
            Mongoid::Config.sessions = config
          end

          let(:session) do
            described_class.create(:secondary)
          end

          let(:cluster) do
            session.cluster
          end

          it "returns a session" do
            session.should be_a(Moped::Session)
          end

          it "sets the cluster's seeds" do
            cluster.seeds.should eq([ "localhost:27017" ])
          end
        end

        context "when configured via a uri" do

          context "when the uri has a single host:port" do

            let(:config) do
              {
                default: { hosts: [ "localhost:27017" ], database: database_id },
                secondary: { uri: "mongodb://localhost:27017/mongoid_test" }
              }
            end

            before do
              Mongoid::Config.sessions = config
            end

            let(:session) do
              described_class.create(:secondary)
            end

            let(:cluster) do
              session.cluster
            end

            it "returns a session" do
              session.should be_a(Moped::Session)
            end

            it "sets the cluster's seeds" do
              cluster.seeds.should eq([ "localhost:27017" ])
            end

            it "sets the database" do
              session.options[:database].should eq("mongoid_test")
            end
          end

          context "when the uri has multiple host:port pairs" do

            let(:config) do
              {
                default: { hosts: [ "localhost:27017" ], database: database_id },
                secondary: { uri: "mongodb://localhost:27017,localhost:27017/mongoid_test" }
              }
            end

            before do
              Mongoid::Config.sessions = config
            end

            let(:session) do
              described_class.create(:secondary)
            end

            let(:cluster) do
              session.cluster
            end

            it "returns a session" do
              session.should be_a(Moped::Session)
            end

            it "sets the cluster's seeds" do
              cluster.seeds.should eq([ "localhost:27017", "localhost:27017" ])
            end

            it "sets the database" do
              session.options[:database].should eq("mongoid_test")
            end
          end
        end
      end

      context "when the configuration does not exist" do

        it "raises an error" do
          expect {
            described_class.create(:unknown)
          }.to raise_error(Mongoid::Errors::NoSessionConfig)
        end
      end
    end

    context "when no name is provided" do

      let(:config) do
        { default: { hosts: ["localhost:27017"], database: database_id }}
      end

      before do
        Mongoid::Config.sessions = config
      end

      let(:session) do
        described_class.create
      end

      let(:cluster) do
        session.cluster
      end

      it "returns the default session" do
        session.should be_a(Moped::Session)
      end

      it "sets the cluster's seeds" do
        cluster.seeds.should eq([ "localhost:27017" ])
      end
    end
  end

  describe ".default" do

    let(:config) do
      { default: { hosts: ["localhost:27017"], database: database_id }}
    end

    before do
      Mongoid::Config.sessions = config
    end

    let(:session) do
      described_class.default
    end

    let(:cluster) do
      session.cluster
    end

    it "returns the default session" do
      session.should be_a(Moped::Session)
    end

    it "sets the cluster's seeds" do
      cluster.seeds.should eq([ "localhost:27017" ])
    end
  end
end
