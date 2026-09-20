# frozen_string_literal: true

require "metanorma/standoc"
require "metanorma/iso/document"
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

require "metanorma-core"

# OCP adoption: ONE registration in the metanorma-core flavor table
# (metanorma-core#18). Lazy: the table exists only on the flavor-table
# line of metanorma-core; skip silently on resolutions without it.
if defined?(Metanorma::Core::Flavors)
  Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                      name: :csa,
                                      gem: "metanorma-csa",
                                      model_root: Metanorma::Csa::Document::Root,
                                      pubid_module: nil,
                                      renderers: { html: lambda do |_document, **_options|
                                        require "metanorma/csa/html"
                                        Metanorma::Csa::Html::Renderer
                                      end },
                                    ))
end
