# frozen_string_literal: true

require "metanorma/standoc"
# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/csa.rb).
module Metanorma
  module Csa
  end
end


module Metanorma
  module Csa::Document
    autoload :Root, "metanorma/csa/document/root"
  end
end


# Backwards-compat alias so external consumers that reference
# Metanorma::CsaDocument keep resolving during the transition.
module Metanorma
  existing = defined?(Metanorma::CsaDocument) && Metanorma::CsaDocument
  if !existing.equal?(Metanorma::Csa::Document)
    Metanorma.send(:remove_const, :CsaDocument) if existing
    CsaDocument = Metanorma::Csa::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_csa_register)
  Metanorma::Registers::Setup.setup_csa_register
end

module Metanorma
  deprecate_constant :CsaDocument
end
