#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def party_info_for(img)
  return ['Partido Revolucionario Institucional', 'PRI'] if img == 'images/pri01.png'
  return ['Partido Acción Nacional', 'PAN'] if img == 'images/pan.png'
  return ['Partido de la Revolución Democrática', 'PRD'] if img == 'images/prd01.png'
  return ['Partido Verde Ecologista', 'PVE'] if img == 'images/logvrd.jpg'
  return ['Movimiento Ciudadano', 'MC'] if img == 'images/logo_movimiento_ciudadano.png'
  return ['Partido del Trabajo', 'PT'] if img == 'images/logpt.jpg'
  return ['Partido Nueva Alianza', 'PANAL'] if img == 'images/panal.gif'
  return ['Movimiento Regeneración Nacional', 'MORENA'] if img == 'images/LogoMorena.jpg'
  return ['Encuentro Social', 'PES'] if img == 'images/encuentro.png'
  return ['Sin Partido', '_IND'] if img == 'images/logo_SP.jpg'
  return ['Sin Partido', '_IND'] if img == 'images/independiente.png'
  raise "Unknown party: #{img}"
end

def ocd(entidad, d_c_text)
  d_c, d_c_no = d_c_text.split(/\.\s+/, 2)
  dc_expanded = {
    'Circ' => 'Circunscripción',
    'Dtto' => 'Distrito',
  }
  area = '%s %s' % [entidad, d_c_no]
  area_id = 'ocd-division/country:mx/entidad:%s/%s:%s' % [entidad, dc_expanded[d_c], d_c_no].map do |str|
    str.downcase.gsub(/[[:space:]]+/, '-')
  end
  [area, area_id]
end

def scrape_list(url)
  noko = noko_for(url)
  table = noko.xpath('//table[.//td[contains(.,"Entidad")]]').last

  party = party_id = nil
  table.xpath('.//tr').each_with_index do |tr, i|
    tds = tr.css('td')
    if tds.size == 1
      if img = tr.css('img/@src').text
        next if img.to_s.empty?
        next if img == 'images/h_line.gif'
        next if img == 'images/lin_por_gp.jpg'
        party, party_id = party_info_for(img)
        warn party.to_s
      end
      next
    end
    next if tds[1].text == 'Entidad'

    mp_url = URI.join url, tds[0].css('a/@href').text

    area, area_id = ocd(tds[1].text.tidy, tds[2].text.tidy)

    data = {
      id:        mp_url.to_s[/dipt=(\d+)/, 1],
      sort_name: tds[0].text.tidy.sub(/^\d+\s*/, '').sub(' (LICENCIA)', ''),
      party:     party,
      party_id:  party_id,
      area_id:   area_id,
      area:      area,
      term:      '63',
    }.merge(scrape_person(mp_url))
    ScraperWiki.save_sqlite(%i(id term), data)
    puts i if (i % 50).zero?
  end
end

def scrape_person(url)
  noko = noko_for(url)
  data = {
    name:   noko.css('td strong').find { |n| n.text.include? 'Dip. ' }.text.sub('Dip. ', '').sub(' (LICENCIA)', '').tidy,
    image:  noko.at_css('img[src*="fotos"]/@src').text,
    email:  noko.xpath('//td[contains(.,"Correo")]').last.xpath('following-sibling::td').text,
    source: url.to_s,
  }
  data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
  data
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list('http://sitl.diputados.gob.mx/LXIII_leg/listado_diputados_gpnp.php?tipot=TOTAL')
