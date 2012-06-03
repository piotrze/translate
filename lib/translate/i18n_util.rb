module Translate
  class I18nUtil

    # Create tanslation records from the YAML file.  Will create the required locales if they do not exist.
    def self.load_from_yml(file_name)
      data = YAML::load(IO.read(file_name))
      data.each do |code, translations|
        locale = Locale.find_or_create_by_iso_code(code)
        keys = Translations::Keys.to_shallow_hash(translations)
        keys.each do |key, value|
          create_translation(locale, key, to_proper_value(value))

        end
      end
    end

    def self.export_to_yml(locale, path)
      translations = Translation.find(:all, :conditions => {:locale_id => locale.id}, :order => '`key`')
      translations_hash = {}
      translations.map{|t| translations_hash["#{locale.iso_code}.#{t.key}".to_sym] = t.value}
      Translations::File.new(::File.join(path, "#{locale.iso_code}.yml")).write(Translations::Keys.to_deep_hash(translations_hash))
    end

    # Finds or creates a translation record and updates the value
    def self.create_translation(locale, key, value)
      translation = locale.translations.find_by_key(key)
      unless translation # or build new one with raw key
        translation = locale.translations.build(:key =>key)
        puts "from yaml create translation for #{locale.iso_code} : #{key} " unless RAILS_ENV['test']
      end
      translation.value = value
      translation.save!
    end


    private
    def self.to_proper_value(object)
      if object.is_a?(String)
        return object
      elsif object.is_a?(Numeric)
        return object
      else
        return object.to_yaml
      end
    end
  end
end
