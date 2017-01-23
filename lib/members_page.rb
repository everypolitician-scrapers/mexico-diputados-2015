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
      # 1. Reject image rows
      # 2. Slice list to separate from other party groupings
      # 3. First item is member rows in required party group
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
      "#{state_name} #{electoral_area_id}"
    end

    field :area_id do
      # ocd division id (http://opencivicdata.readthedocs.io/en/latest/ocdids.html)
      "ocd-division/country:mx/entidad:#{state_id}/#{electoral_area}"
    end

    private

    ## Mexico is divided into Federal Entities (states). Each is divided into
    ## "Distrito"s. A deputy is elected to represent either a "Distrito" or "Circunscripcion".
    ## "Circunscripcion"s are: '...geographic areas composed of various states used
    ## for the election of the 200 proportional representation legislators to
    ## the Chamber of Deputies.' (https://en.wikipedia.org/wiki/Electoral_regions_of_Mexico)
    ## Here, "Distrito"s and "Circunscripcion"s are referred to as 'electoral areas'.

    def state_name
      noko.xpath('td')[1].text
    end

    def state_id
      state_name.split(' ')
                .join('-')
                .downcase
    end

    def electoral_area
      noko.xpath('td')[2]
          .text
          .downcase
          .gsub('circ', 'circunscripción')
          .gsub('dtto', 'distrito')
          .gsub(/\.\s+/, ':')
    end

    def electoral_area_id
      electoral_area.split(':').last
    end
  end
end
