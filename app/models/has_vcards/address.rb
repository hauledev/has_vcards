# encoding: utf-8

module HasVcards
  class Address < ActiveRecord::Base
    # Access restrictions
    attr_accessible :extended_address, :street_address, :post_office_box, :postal_code, :locality, :zip_locality if defined?(ActiveModel::MassAssignmentSecurity)

    belongs_to :vcard

    # Validations
    include I18nHelpers

    def validate_address
      errors.add_on_blank(:postal_code)
      errors.add_on_blank(:locality)

      return unless street_address.blank? && extended_address.blank? && post_office_box.blank?

      errors.add(:street_address, "#{t_attr(:street_address, Vcard)} #{I18n.translate('errors.messages.empty')}")
      errors.add(:extended_address, "#{t_attr(:extended_address, Vcard)} #{I18n.translate('errors.messages.empty')}")
      errors.add(:post_office_box, "#{t_attr(:post_office_box, Vcard)} #{I18n.translate('errors.messages.empty')}")
    end

    # Helpers
    def to_s
      I18n.translate('has_vcards.address.to_s',
                     street_address: street_address,
                     postal_code: postal_code,
                     locality: locality
      )
    end

    # Composed attributes
    def zip_locality
      "#{postal_code} #{locality}"
    end

    def zip_locality=(value)
      self.postal_code, self.locality = value.split(' ', 2)
    end
  end
end
