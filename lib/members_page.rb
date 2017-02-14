# encoding: utf-8
# frozen_string_literal: true
require 'scraped'
require_relative './decorators/party_name_attributes'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls
  decorator PartyNameAttributes

  field :party_groupings do
    noko.xpath('//td/table/tr/td[contains(.,"Circunscripción")]/parent::tr')
        .map do |row|
      fragment row => PartyGroupings
    end
  end

  class PartyGroupings < Scraped::HTML
    field :party do
      party_image_node[:party_name]
    end

    field :party_id do
      party_image_node[:party_id]
    end

    field :members do
      noko.xpath('following-sibling::tr')
          .reject { |row| row.at_xpath('./td/@colspan').to_s >= '3' }
          .slice_before { |i| i.text == noko.text }
          .first.map do |row|
        fragment row => MemberRow
      end
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
      noko.xpath('td').first.text.tidy.sub(/^\d+\s*/, '').sub(' (LICENCIA)', '')
    end

    field :source do
      noko.xpath('td/a/@href').text
    end

    field :area do
      "#{noko.xpath('td')[1].text} #{noko.xpath('td')[2].text.split(' ').last}"
    end

    field :area_id do
      d_c_no = noko.xpath('td')[2]
                   .text
                   .downcase
                   .gsub('circ', 'circunscripción')
                   .gsub('dtto', 'distrito')
                   .gsub(/\.\s+/, ':')
      area_part = area.split(' ').reject { |x| x =~ /\d/ }.join('-').downcase
      "ocd-division/country:mx/entidad:#{area_part}/#{d_c_no}"
    end
  end
end
