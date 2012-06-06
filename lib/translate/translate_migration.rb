class TranslationsMigration < ActiveRecord::Migration
  #it will also creates empty keys for other locales
  def self.add_key(key,value_in_english)
    ActiveRecord::Base.transaction do
      en_locale = 'en'
      Translation.create(:key => key, :value => value_in_english, :locale => en_locale)
      for other_locale in Locale.find_locales
        t = Translation.create!(:key => key, :locale => other_locale)
        puts t
      end
    end
  end

  def self.add_key_in_all_locales(key, value_in_english, code_upcase = true)
    ActiveRecord::Base.transaction do
      en_locale ='en'
      Translation.create(:key => key, :value => value_in_english, :locale => en_locale)
      for other_locale in Locale.find_locales
        if code_upcase
          t = Translation.create!(:key => key, :locale => other_locale, :value=>"[#{other_locale.upcase}] #{value_in_english}")
        else
          t = Translation.create!(:key => key, :locale => other_locale, :value=> value_in_english )
        end
        puts t
      end
    end
  end

  # update key for locales
  def self.update_key(key, value, locales)
    ActiveRecord::Base.transaction do
      locales.each do |l|
        if translation = Translation.find_by_key_and_locale(key, l)
          translation.value = value
          translation.save
        else
          raise "Translation for key: #{key} and locale: #{l} not found."
        end
      end
    end

  end
end
