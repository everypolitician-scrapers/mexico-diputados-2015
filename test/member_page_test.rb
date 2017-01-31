# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/member_page.rb'

describe MemberPage do
  around { |test| VCR.use_cassette('Patricia Sánchez Carillo', &test) }

  subject do
    url = 'http://sitl.diputados.gob.mx/LXIII_leg/curricula.php?dipt=388'
    MemberPage.new(response: Scraped::Request.new(url: url).response).to_h
  end

  it 'should have the correct :name' do
    subject[:name].must_equal 'Patricia Sánchez Carrillo'
  end

  it 'should have the correct :image' do
    subject[:image].must_equal 'http://sitl.diputados.gob.mx/LXIII_leg/fotos_lxiiiconfondo/457_FOTO_CHICA.jpg'
  end

  it 'should have the correct :email' do
    subject[:email].must_equal 'psanchez.carrillo@congreso.gob.mx '
  end
end
