# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe Metanorma::Csa do
  it "has a version number" do
    expect(Metanorma::Csa::VERSION).not_to be nil
  end

  it "processes a blank document" do
    input = Asciidoctor.convert(ASCIIDOC_BLANK_HDR, backend: :csa, header_footer: true)
    expect(xmlpp(strip_guid(input))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{BLANK_HDR}
      <sections/>
      </csa-standard>
    OUTPUT
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.pdf"
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    #{BLANK_HDR}
<sections/>
</csa-standard>
    OUTPUT
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.pdf")).to be true
  end

  it "processes default metadata" do
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
      :technical-committee: TC
      :technical-committee-type: A
      :technical-committee_2: TC1
      :technical-committee-type_2: B
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :secretariat: SECRETARIAT
      :copyright-year: 2001
      :status: working-draft
      :iteration: 3
      :language: en
      :title: Main Title
      :fullname: Fred Nerk
      :surname_2: Caesar
      :givenname_2: Julius
      :role_2: contributor
    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
<csa-standard xmlns="https://www.metanorma.org/ns/csa" type="semantic" version="#{Metanorma::Csa::VERSION}">
<bibdata type="standard">
<title language="en" format="text/plain">Main Title</title>
<docidentifier type="CSA">1000(wd):2001</docidentifier>
<docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>Cloud Security Alliance</name>
      <abbreviation>CSA</abbreviation>
    </organization>
  </contributor>
           <contributor>
             <role type='author'>
               <description>full-author</description>
             </role>
             <person>
               <name>
                 <completename>Fred Nerk</completename>
               </name>
             </person>
           </contributor>
           <contributor>
             <role type='author'>
               <description>contributor</description>
             </role>
             <person>
               <name>
                 <forename>Julius</forename>
                 <surname>Caesar</surname>
               </name>
             </person>
           </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Cloud Security Alliance</name>
      <abbreviation>CSA</abbreviation>
    </organization>
  </contributor>
    <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>working-draft</stage>
    <iteration>3</iteration>
  </status>
  <copyright>
    <from>2001</from>
    <owner>
      <organization>
        <name>Cloud Security Alliance</name>
        <abbreviation>CSA</abbreviation>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>standard</doctype>
  <editorialgroup>
    <committee type="A">TC</committee>
    <committee type="B">TC1</committee>
  </editorialgroup>
  </ext>
</bibdata>
    #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement").sub(/#{Date.today.year} Cloud Security Alliance/, "2001 Cloud Security Alliance")}
<sections/>
</csa-standard>
    OUTPUT
  end

  it "processes committee-draft" do
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :status: committee-draft
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
      <csa-standard xmlns="https://www.metanorma.org/ns/csa" type="semantic" version="#{Metanorma::Csa::VERSION}">
      <bibdata type="standard">
        <title language="en" format="text/plain">Main Title</title>
        <docidentifier type="CSA">1000(cd):#{Time.now.year}</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>Cloud Security Alliance</name>
            <abbreviation>CSA</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>Cloud Security Alliance</name>
            <abbreviation>CSA</abbreviation>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>committee-draft</stage>
          <iteration>3</iteration>
        </status>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>Cloud Security Alliance</name>
              <abbreviation>CSA</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
        <doctype>standard</doctype>
        </ext>
      </bibdata>
    #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement")}
      <sections/>
      </csa-standard>
    OUTPUT
  end

  it "processes draft-standard" do
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :status: draft-standard
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
      <csa-standard xmlns="https://www.metanorma.org/ns/csa" type="semantic" version="#{Metanorma::Csa::VERSION}">
      <bibdata type="standard">
        <title language="en" format="text/plain">Main Title</title>
        <docidentifier type="CSA">1000(d):#{Time.now.year}</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>Cloud Security Alliance</name>
            <abbreviation>CSA</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>Cloud Security Alliance</name>
            <abbreviation>CSA</abbreviation>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>draft-standard</stage>
          <iteration>3</iteration>
        </status>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>Cloud Security Alliance</name>
              <abbreviation>CSA</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
        <doctype>standard</doctype>
        </ext>
      </bibdata>
    #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement")}
      <sections/>
      </csa-standard>
    OUTPUT
  end

  it "ignores unrecognised status" do
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :copyright-year: 2001
      :status: standard
      :iteration: 3
      :language: en
      :title: Main Title
    INPUT
      <csa-standard xmlns="https://www.metanorma.org/ns/csa" type="semantic" version="#{Metanorma::Csa::VERSION}">
      <bibdata type="standard">
        <title language="en" format="text/plain">Main Title</title>
        <docidentifier type="CSA">1000:2001</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>Cloud Security Alliance</name>
            <abbreviation>CSA</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>Cloud Security Alliance</name>
            <abbreviation>CSA</abbreviation>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>standard</stage>
          <iteration>3</iteration>
        </status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>Cloud Security Alliance</name>
              <abbreviation>CSA</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
        <doctype>standard</doctype>
        </ext>
      </bibdata>
    #{BOILERPLATE.sub(/<legal-statement/, "#{LICENSE_BOILERPLATE}\n<legal-statement").sub(/#{Date.today.year} Cloud Security Alliance/, "2001 Cloud Security Alliance")}
      <sections/>
      </csa-standard>
    OUTPUT
  end

  it "processes figures" do
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [[id]]
      .Figure 1
      ....
      This is a literal

      Amen
      ....
    INPUT
      #{BLANK_HDR}
      <sections>
        <figure id="id">
          <name>Figure 1</name>
          <pre id="_">This is a literal

       Amen</pre>
       </figure>
       </sections>
       </csa-standard>
    OUTPUT
  end

  it "strips inline header" do
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
      INPUT
    #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title>Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </csa-standard>
    OUTPUT
  end

  it "uses default fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :csa, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Source Code Pro", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: Lato, "Source Sans Pro", sans-serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Lato, "Source Sans Pro", sans-serif;]m)
  end

  it "uses specified fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :csa, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Space Mono
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: Space Mono;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes inline_quoted formatting" do
    args = { backend: :csa, header_footer: true }
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", args)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      _emphasis_
      *strong*
      `monospace`
      "double quote"
      'single quote'
      super^script^
      sub~script~
      stem:[a_90]
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [keyword]#keyword#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT
            #{BLANK_HDR}
       <sections>
        <p id="_"><em>emphasis</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       “double quote”
       ‘single quote’
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>a</mi>
</mrow>
<mrow>
  <mn>90</mn>
</mrow>
</msub></math></stem> 
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       <keyword>keyword</keyword>
       <strike>strike</strike>
       <smallcap>smallcap</smallcap></p>
       </sections>
       </csa-standard>
    OUTPUT
  end


end
