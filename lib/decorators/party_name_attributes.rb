# frozen_string_literal: true
require 'scraped'

# Members on the members page are grouped by party but the names or ids of the
# parties are not given. Instead, each party is signified by an image.

# This decorator maps the party name and id to the image name and populates the
# party image <img> tags with party_name and party_id attributes.
class PartyNameAttributes < Scraped::Response::Decorator
  PARTY_IMAGE_MAP = {
    'pri01.png'                     => ['Partido Revolucionario Institucional', 'PRI'],
    'pan.png'                       => ['Partido Acción Nacional', 'PAN'],
    'prd01.png'                     => ['Partido de la Revolución Democrática', 'PRD'],
    'logvrd.jpg'                    => ['Partido Verde Ecologista', 'PVE'],
    'logo_movimiento_ciudadano.png' => ['Movimiento Ciudadano', 'MC'],
    'logpt.jpg'                     => ['Partido del Trabajo', 'PT'],
    'panal.gif'                     => ['Partido Nueva Alianza', 'PANAL'],
    'LogoMorena.jpg'                => ['Movimiento Regeneración Nacional', 'MORENA'],
    'encuentro.png'                 => ['Encuentro Social', 'PES'],
    'logo_SP.jpg'                   => ['Sin Partido', '_IND'],
    'independiente.png'             => ['Sin Partido', '_IND'],
  }.freeze

  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('img').each do |img|
        key = File.basename(img[:src])
        party_data = PARTY_IMAGE_MAP[key] or next
        img[:party_id] = party_data.last
        img[:party_name] = party_data.first
      end
    end.to_s
  end
end
