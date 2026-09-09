# frozen_string_literal: true

module Metanorma
  module Csa
    module Html
      # CSA documents render iso-style; the CSA root uses the ISO
      # section classes the parent renderer already registers — only
      # the root itself needs dispatch (exact-class, OGC pattern).
      class Renderer < Metanorma::Iso::Html::Renderer
        register_render "Metanorma::Csa::Document::Root", :render_document
      end
    end
  end
end
