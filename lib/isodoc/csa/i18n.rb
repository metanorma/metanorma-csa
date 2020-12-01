module IsoDoc
  module Csa
    class I18n < IsoDoc::Generic::I18n
      def configuration
        Metanorma::Csa.configuration
      end
    end
  end
end
