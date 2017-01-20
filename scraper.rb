#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
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

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  data = (scrape url => MembersPage).member_rows
                                    .map do |row|
                                      row.merge((scrape row[:source] => MemberPage).to_h)
                                         .merge(term: '63')
                                    end
  ScraperWiki.save_sqlite(%i(id term), data)
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list('http://sitl.diputados.gob.mx/LXIII_leg/listado_diputados_gpnp.php?tipot=TOTAL')
