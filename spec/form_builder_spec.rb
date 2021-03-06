# encoding: utf-8

require 'spec_helper'

describe Formative::FormBuilder do

  include FormativeSpecHelper

  let(:template) { mock_template }
  let(:date_attribute) { mock('attribute', :day => 1, :month => 1, :year => 2000) }
  let(:text_attribute) { 'THE_VALUE' }
  let(:model) { mock('model', :attribute => attribute) }

  subject { Formative::FormBuilder.new(:model, model, template, {}, Proc.new {}) }

  {
    :text_field => [],
    :select => [ [] ],
    :collection_select => [ [Struct.new(:value, :text).new], :value, :text ],
    :password_field => [],
    :text_area => [],
    :date_select => [],
    :check_box => []
  }.each_pair do |builder_method, additional_args|

    describe "##{builder_method}" do
      let(:attribute) { builder_method == :date_select ? date_attribute : text_attribute }
      let(:args) { [builder_method, :attribute].concat additional_args }

      it 'should output a default wrapper' do
        tag = subject.send(*args)
        tag.should =~ /^<p/
        tag.should =~ /<\/p\>$/
      end

      it 'should output a given wrapper' do
        tag = subject.send(*(args << {:wrapper => :div}))
        tag.should =~ /^<div/
        tag.should =~ /<\/div\>$/
      end

      it 'should add "field <method_name> <field_name>" as class of wrapper' do
        subject.send(*args).should =~ /^<p class="field #{builder_method.to_s.dasherize} attribute"/
      end

      it 'should output a proper label' do
        subject.send(*args).should =~ /<label for="model_attribute".*\/label>/
      end

      it 'should output a given unit' do
        subject.send(*(args << {:unit => 'the unit'})).should =~ /<span class="unit">the unit<\/span>/
      end

      it 'should output a given hint' do
        subject.send(*(args << {:hint => 'additional information'})).should =~ /<span class="hint">additional information<\/span>/
      end

      context ":wrapper => false" do
        let(:no_wrapper_args) { args << {:wrapper => false} }

        it 'should not output a wrapper' do
          subject.send(*no_wrapper_args).should_not =~ /^<p/
          subject.send(*no_wrapper_args).should_not =~ /\/p>$/
        end

        it 'should not output the wrapper option into the tag attributes' do
          subject.send(*no_wrapper_args).should_not =~ /wrapper\s*=/
        end
      end

      context ":label => false" do
        let(:no_label_args) { args << {:label => false} }

        it 'should not output a label' do
          subject.send(*no_label_args).should_not =~ /<label/
          subject.send(*no_label_args).should_not =~ /\/label>/
        end

        it 'should not output the label option into the tag attributes' do
          subject.send(*no_label_args).should_not =~ /label\s*=/
        end
      end

      context ":hint => false" do
        let(:no_hint_args) { args << {:hint => false} }

        it 'should not output a hint' do
          subject.send(*no_hint_args).should_not =~ /<\w+ class="hint"/
        end

        it 'should not output the hint option into the tag attributes' do
          subject.send(*no_hint_args).should_not =~ /hint\s*=/
        end
      end

      context ":unit => false" do
        let(:no_unit_args) { args << {:unit => false} }

        it 'should not output a unit' do
          subject.send(*no_unit_args).should_not =~ /<\w+ class="unit"/
        end

        it 'should not output the unit option into the tag attributes' do
          subject.send(*no_unit_args).should_not =~ /unit\s*=/
        end
      end
    end

  end

end
