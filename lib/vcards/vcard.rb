module Vcards
  class Vcard < ActiveRecord::Base
    has_one :address
    has_one_delegate :address

    has_many :addresses

    named_scope :active, :conditions => {:active => true}
    named_scope :by_name, lambda {|name| {:conditions => self.by_name_conditions(name)}}

    belongs_to :object, :polymorphic => true

    # Convenience accessors
    def full_name
      result = read_attribute(:full_name)
      result ||= [ family_name, given_name ].compact.join(' ')

      return result
    end

    def abbreviated_name
      "#{given_name[0..0]}. #{family_name}"
    end

    # Advanced finders
    def self.by_name_conditions(name)
      ['vcards.full_name LIKE :name OR vcards.family_name LIKE :name OR vcards.given_name LIKE :name OR vcards.nickname LIKE :name', {:name => name}]
    end

    def self.find_by_name(name)
      self.find(:first, :conditions => self.by_name_conditions(name))
    end

    def self.find_all_by_name(name)
      self.find(:all, :conditions => self.by_name_conditions(name))
    end

    # Helper methods
    def address_lines
      lines = [street_address, "#{postal_code} #{locality}"]

      # Only return non-empty lines
      lines.map {|line| line.strip unless (line.nil? or line.strip.empty?)}
    end

    def full_address_lines
      lines = [honorific_prefix, full_name] + address_lines

      # Only return non-empty lines
      lines.map {|line| line.strip unless (line.nil? or line.strip.empty?)}
    end

    def contact_lines
      lines = contacts.map{|p| p.to_s}
      
      # Only return non-empty lines
      lines.map {|line| line.strip unless (line.nil? or line.strip.empty?)}
    end

    # Phone numbers
    has_many :contacts, :class_name => 'PhoneNumber'

    has_many :phone_numbers, :class_name => 'PhoneNumber', :conditions => ["phone_number_type = ?", 'phone'], :after_add => :add_phone_number
    def add_phone_number(number)
        number.phone_number_type = 'phone'
        number.save
    end

    has_many :mobile_numbers, :class_name => 'PhoneNumber', :conditions => ["phone_number_type = ?", 'mobile'], :after_add => :add_mobile_number
    def add_mobile_number(number)
        number.phone_number_type = 'mobile'
        number.save
    end

    has_many :fax_numbers, :class_name => 'PhoneNumber', :conditions => ["phone_number_type = ?", 'fax'], :after_add => :add_fax_number
    def add_fax_number(number)
        number.phone_number_type = 'fax'
        number.save
    end

    # Salutation
    def salutation
      case honorific_prefix
      when 'Herr Dr. med.'
        result = "Sehr geehrter Herr Dr. " + family_name
      when 'Frau Dr. med.'
        result = "Sehr geehrte Frau Dr. " + family_name
      when 'Herr Dr.'
        result = "Sehr geehrter Herr Dr. " + family_name
      when 'Frau Dr.'
        result = "Sehr geehrte Frau Dr. " + family_name
      when 'Herr'
        result = "Sehr geehrter Herr " + family_name
      when 'Frau'
        result = "Sehr geehrte Frau " + family_name
      when 'Br.'
        result = "Sehr geehrter Bruder " + family_name
      when 'Sr.'
        result = "Sehr geehrte Schwester " + family_name
      else
        result = "Sehr geehrte Damen und Herren"
      end
      return result
    end
  end
end
