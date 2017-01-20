# encoding: utf-8
# frozen_string_literal: true

require 'scraped'
class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :name do
    noko.css('td strong')
        .find { |n| n.text.include? 'Dip. ' }
        .text
        .sub('Dip. ', '')
        .sub(' (LICENCIA)', '')
        .tidy
  end

  field :image do
    noko.at_css('img[src*="fotos"]/@src')
        .text
  end

  field :email do
    noko.xpath('//td[contains(.,"Correo")]')
        .last
        .xpath('following-sibling::td')
        .text
  end
end
