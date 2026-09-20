# frozen_string_literal: true

require "bundler/setup"
require "rspec/matchers"
require "metanorma/csa/document"
require_relative "support/roundtrip_helper"
require_relative "support/shared_roundtrip_examples"

require "metanorma/csa_document"

RSpec.describe "CSA document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "csa",
                                    doc_class: Metanorma::Csa::Document::Root
end
