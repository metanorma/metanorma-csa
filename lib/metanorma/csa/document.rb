# frozen_string_literal: true

require "metanorma/standoc"
require "metanorma/iso/document/models"
module Metanorma
  module Csa
  end
end

module Metanorma
  module Csa::Document
  end
end

module Metanorma
  existing = defined?(Metanorma::CsaDocument) && Metanorma::CsaDocument
  if !existing.equal?(Metanorma::Csa::Document)
    Metanorma.send(:remove_const, :CsaDocument) if existing
    CsaDocument = Metanorma::Csa::Document
  end
end

# OCP adoption: ONE registration in the metanorma-core flavor table
require "metanorma-core"
require "metanorma/iso/html"

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :csa,
  gem: "metanorma-csa",
  model_root: Metanorma::Csa::Document::Root,
  pubid_module: :"Pubid::Csa",
  renderers: { html: Metanorma::Iso::Html::Renderer },
))
