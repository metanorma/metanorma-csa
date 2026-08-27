# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Csa
    # csa's lutaml-model register: type substitutions from standoc.
    # Formerly Metanorma::Registers::Setup.setup_csa_register in metanorma-document.
    module Registers
      module_function

      def setup
          reg = Lutaml::Model::Register.new(:csa_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)
      end
    end
  end
end
