#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

require_rel 'lib'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def data_for_members(term, url)
  (scrape url => MembersPage).party_groupings.flat_map do |party|
    party.members.map do |mem|
      party.to_h.reject { |k| k == :members }
           .merge(term: term)
           .merge(mem.to_h)
           .merge((scrape mem.source => MemberPage).to_h)
    end
  end
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
data = data_for_members('63', 'http://sitl.diputados.gob.mx/LXIII_leg/listado_diputados_gpnp.php?tipot=TOTAL')
ScraperWiki.save_sqlite(%i(id term), data)
