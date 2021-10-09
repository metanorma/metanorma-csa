# frozen_string_literal: true

require "isodoc"

module IsoDoc
  module Csa
    module BaseConvert
      def configuration
        Metanorma::Csa.configuration
      end
    end
  end
end
