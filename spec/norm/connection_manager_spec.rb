require 'spec_helper'

module Norm
  describe ConnectionManager do
    subject { ConnectionManager }

    class ConnectionManagerSpecDB
      attr_reader :options, :execs
      def initialize(options = {})
        @options = options
        @execs   = []
      end

      def exec(str)
        @execs << str
      end
    end

    def with_fake_db(&block)
      PG::Connection.stub(:new, ->(options = {}) {
        ConnectionManagerSpecDB.new(options)
      }, &block)
    end

    it 'always has a primary connection pool' do
      with_fake_db do
        mgr = subject.new
        mgr.pools.size.must_equal 1
        mgr.pools[:primary].must_be_kind_of ConnectionPool
      end
    end

    it 'defaults to pool size and timeout of 5' do
      with_fake_db do
        mgr = subject.new
        primary = mgr.pools[:primary]
        primary.instance_variable_get(:@size).must_equal 5
        primary.instance_variable_get(:@timeout).must_equal 5
      end
    end

    it 'allows specification of pool size and timeout' do
      with_fake_db do
        mgr = subject.new(:primary => {'pool' => 3, 'pool_timeout' => 3})
        primary = mgr.pools[:primary]
        primary.instance_variable_get(:@size).must_equal 3
        primary.instance_variable_get(:@timeout).must_equal 3
      end
    end

    it 'passes other options to underlying db' do
      with_fake_db do
        mgr = subject.new(:primary => {'pool' => 3, 'foo' => 'bar'})
        mgr.pools[:primary].with do |primary|
          primary.db.options.must_equal 'foo' => 'bar'
        end
      end
    end

    describe '#with_connection(s)' do
      let(:spec) { {
        :primary => {'host' => 'zomg.bbq'},
        :reader  => {'host' => 'foo.bar'},
        :writer  => {'host' => 'mahna.mahna'}
      } }
      subject { ConnectionManager.new(spec) }

      it 'yields a single connection' do
        with_fake_db do
          subject.with_connections(:primary) do |primary|
            primary.db.options['host'].must_equal 'zomg.bbq'
          end
        end
      end

      it 'yields multiple connections' do
        with_fake_db do
          subject.with_connections(
            :primary, :reader, :writer
          ) do |primary, reader, writer|
            primary.db.options['host'].must_equal 'zomg.bbq'
            reader.db.options['host'].must_equal 'foo.bar'
            writer.db.options['host'].must_equal 'mahna.mahna'
          end
        end
      end

      it 'requires a connection name when called as singular' do
        with_fake_db do
          proc { subject.with_connection {} }.must_raise ArgumentError
        end
      end

    end

    describe '#atomically_on' do
      let(:spec) { {
        :primary => {'host' => 'zomg.bbq'},
        :reader  => {'host' => 'foo.bar'},
        :writer  => {'host' => 'mahna.mahna'}
      } }
      subject { ConnectionManager.new(spec) }

      it 'creates transactions on each connection' do
        with_fake_db do
          subject.atomically_on(:primary, :reader, :writer) do |p, r, w|
            p.must_be_kind_of Connection
            r.must_be_kind_of Connection
            w.must_be_kind_of Connection
          end
          subject.with_connections(:primary, :reader, :writer) do |p, r, w|
            p.db.execs.must_equal ['BEGIN', 'COMMIT']
            r.db.execs.must_equal ['BEGIN', 'COMMIT']
            w.db.execs.must_equal ['BEGIN', 'COMMIT']
          end
        end
      end

      it 'returns an unsuccessful result on constraint errors if handling' do
        with_fake_db do
          result = subject.atomically_on(
            :primary, :reader, :writer, handle_constraints: true
          ) do |p, r, w|
            p.must_be_kind_of Connection
            r.must_be_kind_of Connection
            w.must_be_kind_of Connection
            raise ConstraintError.new(PG::CheckViolation.new)
          end
          subject.with_connections(:primary, :reader, :writer) do |p, r, w|
            p.db.execs.must_equal ['BEGIN', 'ROLLBACK']
            r.db.execs.must_equal ['BEGIN', 'ROLLBACK']
            w.db.execs.must_equal ['BEGIN', 'ROLLBACK']
          end

          result.wont_be :success?
          result.constraint_error.must_be_kind_of ConstraintError
        end
      end

      it 'creates savepoints on connections when needed' do
        with_fake_db do
          subject.atomically_on(:primary, :reader, :writer) do |p, r, w|
            p.must_be_kind_of Connection
            r.must_be_kind_of Connection
            w.must_be_kind_of Connection
            subject.atomically_on(:primary) {}
          end
          subject.with_connections(:primary, :reader, :writer) do |p, r, w|
            p.db.execs.must_equal [
              'BEGIN',
              'SAVEPOINT primary_0',
              'RELEASE SAVEPOINT primary_0',
              'COMMIT'
            ]
            r.db.execs.must_equal ['BEGIN', 'COMMIT']
            w.db.execs.must_equal ['BEGIN', 'COMMIT']
          end
        end
      end

      it 'rolls back all transactions on error' do
        with_fake_db do
          error = proc {
            subject.atomically_on(:primary, :reader, :writer) do |p, r, w|
              p.must_be_kind_of Connection
              r.must_be_kind_of Connection
              w.must_be_kind_of Connection
              raise 'zomg'
            end
          }.must_raise RuntimeError
          error.message.must_equal 'zomg'
          subject.with_connections(:primary, :reader, :writer) do |p, r, w|
            p.db.execs.must_equal ['BEGIN', 'ROLLBACK']
            r.db.execs.must_equal ['BEGIN', 'ROLLBACK']
            w.db.execs.must_equal ['BEGIN', 'ROLLBACK']
          end
        end
      end

    end

  end
end
