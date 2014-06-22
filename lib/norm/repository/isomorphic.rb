module Norm
  class Repository
    class Isomorphic < Repository

      def table_name
        raise NotImplementedError,
          'Isomorphic repositories must implement #table_name'
      end

      def select_statement
        Norm::SQL.select.from(table_name)
      end

      def insert_statement
        Norm::SQL.insert(table_name, attribute_names).returning('*')
      end

      def update_statement
        Norm::SQL.update(table_name).returning('*')
      end

      def delete_statement
        Norm::SQL.delete(table_name).returning('*')
      end

    end
  end
end
