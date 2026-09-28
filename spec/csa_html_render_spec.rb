# frozen_string_literal: true

# Self-contained: avoids the gem spec_helper's heavier requires.
require "bundler/setup"
require "metanorma/csa/document"
require "metanorma/csa/html"
require "metanorma/html/generator"

# The renderer registration contract: the CSA root must dispatch — an
# unregistered root renders reader chrome with no document body.
RSpec.describe "Metanorma::Csa::Html::Renderer" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" \
type="presentation" flavor="csa">
        <bibdata type="standard"><title>CSA Test</title></bibdata>
        <sections><clause id="_c1" obligation="normative">
          <title>Scope</title><p id="_p1">The scope.</p>
        </clause></sections>
      </metanorma>
    XML
  end

  it "renders the CSA root to a document body, not an empty shell" do
    model = Metanorma::Csa::Document::Root.from_xml(xml)
    html = Metanorma::Html::Generator.generate(model)
    page = Nokogiri::HTML(html)
    page.css("header, nav, .header-actions, button, kbd").remove

    expect(page.css("p").size).to be >= 1,
                                  "document body rendered no content (root dispatch missing)"
    expect(page.at("body").text).to include("The scope.")
  end

  it "is the renderer the flavor registry resolves" do
    entry = Metanorma::Core::Flavors.find(:csa)
    expect(entry.renderers[:html].call(nil)).to eq(Metanorma::Csa::Html::Renderer)
  end
end
