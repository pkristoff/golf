# frozen_string_literal: true

describe 'Internal' do

  describe 'app' do

    it 'should pass controllers' do
      expect(system 'rubocop app/controllers/').to eq(true)
    end

    it 'should pass app helpers' do
      expect(system 'rubocop app/helpers/').to eq(true)
    end

    it 'should pass mailers' do
      expect(system 'rubocop app/mailers').to eq(true)
    end

    it 'should pass models' do
      expect(system 'rubocop app/models').to eq(true)
    end

    it 'should pass  views' do
      expect(system 'rubocop app/views').to eq(true)
    end
  end

  describe 'db' do
    it 'should pass migration' do
      expect(system 'rubocop db/migrate').to eq(true)
    end
  end

  describe 'spec' do
    it 'should pass controller spec' do
      expect(system 'rubocop spec/controllers').to eq(true)
    end

    it 'should pass factories spec' do
      expect(system 'rubocop spec/factories').to eq(true)
    end

    it 'should pass models spec' do
      expect(system 'rubocop spec/models').to eq(true)
    end

    it 'should pass views visitors spec' do
      expect(system 'rubocop spec/views').to eq(true)
    end
  end

  describe 'gemspec' do
    it 'should pass gemspec' do
      expect(system 'rubocop Gemfile').to eq(true)
    end
  end

  describe 'rubocop extension' do
    it 'should pass initializers' do
      expect(system 'rubocop spec/rubocop/cop/style/method_documentation.rb').to eq(true)
      expect(system 'rubocop spec/method_documentation_spec.rb').to eq(true)
    end
  end
end
