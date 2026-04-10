module Backend
  module Providers
    module Dental
      class BaseProvider
        private

        def not_implemented!(method_name)
          raise NotImplementedError, "#{self.class.name} must implement ##{method_name}"
        end
      end
    end
  end
end
