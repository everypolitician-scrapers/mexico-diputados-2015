# encoding: utf-8
# frozen_string_literal: true
require 'scraped'
require_relative './decorators/party_name_attributes'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls
  decorator PartyNameAttributes

  field :party_groupings do
    trs = noko.xpath('//td[contains(.,"Distrito / Circunscripción")]/table/tr')
    rows = trs.xpath('td[contains(.,"Circunscripción")]/parent::tr')

    rows.map do |row|
      fragment row => PartyGroupings
    end
  end

  class PartyGroupings < Scraped::HTML
    field :name do
      party_image_node[:party_name]
    end

    field :id do
      party_image_node[:party_id]
    end

    field :members do
      noko.xpath('following-sibling::tr').slice_before { |i| i.text == noko.text }
          .first.map do |row|
        span = row.at_xpath('./td/@colspan')
        next if span.to_s == '3'
        fragment row => MemberRow
      end.reject(&:nil?)
    end

    private

    def party_image_node
      noko.xpath('preceding-sibling::tr/td/img').last
    end
  end

  class MemberRow < Scraped::HTML
    field :id do
      source.to_s[/dipt=(\d+)/, 1]
    end

    field :sort_name do
      noko.xpath('td').text.tidy.sub(/^\d+\s*/, '').sub(' (LICENCIA)', '')
    end

    field :source do
      noko.xpath('td/a/@href').text
    end

    field :area do
      noko.xpath('td')[1].text rescue binding.pry
    end

    field :area_id do
      d_c_no = noko.xpath('td')[2]
                   .text
                   .downcase
                   .gsub('circ', 'circunscripción')
                   .gsub('dtto', 'distrito')
                   .gsub(/\.\s+/, ':')
      "ocd-division/country:mx/entidad:#{area.downcase}/#{d_c_no}"
    end
  end
end
