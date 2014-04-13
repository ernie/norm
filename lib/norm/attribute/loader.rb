module Norm
  module Attribute
    class Loader

      def initialize(fallback = nil)
        @fallback = fallback
        @loaders  = {}
      end

      def load(key, value, *args)
        dispatch(key.to_s, value, *args).load(value, *args)
      end

      def set_loader(key, obj)
        @loaders[key.to_s] = obj
      end

      def loader_for(key, value, *args)
        @loaders[key] || fallback_loader_for(key, value, *args)
      end

      def loader_missing(key, value, *args)
        fallback_loader_missing(key, value, *args)
      end

      private

      def dispatch(key, value, *args)
        loader_for(key, value, *args) || loader_missing(key, value, *args)
      end

      def fallback_loader_for(key, value, *args)
        @fallback.loader_for(key, value, *args) if @fallback
      end

      def fallback_loader_missing(key, value, *args)
        if @fallback
          @fallback.loader_missing(key, value, *args)
        else
          raise LoadingError, "No loader for \"#{key}\" is defined"
        end
      end

    end
  end
end
