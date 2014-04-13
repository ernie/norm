module Norm
  module Attribute
    class Loader

      def initialize(inherited = nil)
        @inherited = inherited
        @loaders  = {}
      end

      def load(key, value, *args)
        dispatch(key.to_s, value, *args).load(value, *args)
      end

      def set_loader(key, obj)
        @loaders[key.to_s] = obj
      end

      def loader_for(key, value, *args)
        @loaders[key] || inherited_loader_for(key, value, *args)
      end

      def loader_missing(key, value, *args)
        inherited_loader_missing(key, value, *args)
      end

      private

      def dispatch(key, value, *args)
        loader_for(key, value, *args) || loader_missing(key, value, *args)
      end

      def inherited_loader_for(key, value, *args)
        @inherited.loader_for(key, value, *args) if @inherited
      end

      def inherited_loader_missing(key, value, *args)
        if @inherited
          @inherited.loader_missing(key, value, *args)
        else
          raise LoadingError, "No loader for \"#{key}\" is defined"
        end
      end

    end
  end
end
