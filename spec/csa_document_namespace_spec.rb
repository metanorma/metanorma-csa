# frozen_string_literal: true

# Self-contained: avoids pulling in the gem's full spec_helper (which
# may load unrelated code with pre-existing pubid-* dependency issues).
require "bundler/setup"
require "metanorma/csa/document"

RSpec.describe "Metanorma::Csa::Document namespace" do
  describe "canonical namespace" do
    it "exposes Metanorma::Csa::Document as a Module" do
      expect(Metanorma::Csa::Document).to be_a(Module)
    end

    it "exposes Root with the canonical name" do
      expect(Metanorma::Csa::Document::Root.name)
        .to eq("Metanorma::Csa::Document::Root")
    end

    it "Root is a lutaml Serializable" do
      expect(Metanorma::Csa::Document::Root < Lutaml::Model::Serializable).to be(true)
    end
  end

  describe "backwards-compat alias" do
    it "Metanorma::CsaDocument aliases to the new namespace" do
      expect(Metanorma::CsaDocument).to eq(Metanorma::Csa::Document)
    end

    it "the alias preserves class identity" do
      expect(Metanorma::CsaDocument::Root.equal?(
               Metanorma::Csa::Document::Root)).to be(true)
    end
  end

  describe "parent namespace" do
    it "Metanorma::Standoc::Document is available" do
      expect(Metanorma::Standoc::Document).to be_a(Module)
    end

    it "Metanorma::StandardDocument alias is available" do
      expect(Metanorma::StandardDocument).to eq(Metanorma::Standoc::Document)
    end
  end
end
