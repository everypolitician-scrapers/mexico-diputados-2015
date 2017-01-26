# frozen_string_literal: true
require 'scraped'

class PartyNameAttributes < Scraped::Response::Decorator
  PARTY_IMAGES_MAPPED =
    {
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
        p = party_name_and_id(img)
        next if p.empty?
        img[:party_name] = p.values.first.first
        img[:party_id] = p.values.first.last
      end
    end.to_s
  end

  private

  def party_name_and_id(img)
    PARTY_IMAGES_MAPPED.select { |k, _v| img[:src].include? k }
  end
end
