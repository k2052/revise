module Revise
  module Helpers
    module Core
      def revise_for(*resources)
        Revise.app = self

        options = resources.extract_options!

        resources.each do |resource|
          begin
            if Revise::MODULES.has_key?(resource)
              models = Revise::MODULES[resource]
              models.each do |m|
                model = Revise::Models.const_get(m)
                add_helpers(model)
                add_controllers(model)
                add_mailers(model)
              end
            else
              Padrino.logger.error "Hey man #{resource} doesn't exist"
            end
          rescue Exception => e
            Padrino.logger.error "Failed to load: #{resource} Because #{e.message()}"
          end
        end
      end

      private
        def add_helpers(model)
          model::HELPERS.each do |helper|
            self.helpers(Revise::Helpers.const_get(helper))
          end
        end

        def add_controllers(model)
           model::CONTROLLERS.each do |controller|
            self.send(:extend, Revise::Controllers.const_get(controller))
          end
        end

        def add_mailers(model)
          model::MAILERS.each do |mailer|
            self.send(:extend, Revise::Mailers.const_get(mailer))
          end
        end
    end
  end
end
