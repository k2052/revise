module Revise
  module Controllers
    module Main
      def self.extended(klass)
        klass.controllers :main do
          get :index, :map => '/',  :priority => :low do
            render "main/index"
          end
        end
      end
    end
  end
end
