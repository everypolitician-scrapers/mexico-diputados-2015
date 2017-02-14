# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/member_page.rb'

describe MemberPage do
  around { |test| VCR.use_cassette('Patricia Sánchez Carillo', &test) }

  subject do
    url = 'http://sitl.diputados.gob.mx/LXIII_leg/curricula.php?dipt=388'
    MemberPage.new(response: Scraped::Request.new(url: url).response)
  end

  it 'should have the expected data' do
    subject.to_h.must_equal(
      name:  'Patricia Sánchez Carrillo',
      image: 'http://sitl.diputados.gob.mx/LXIII_leg/fotos_lxiiiconfondo/457_FOTO_CHICA.jpg',
      email: 'psanchez.carrillo@congreso.gob.mx '
    )
  end
end
