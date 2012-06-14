class Translation < ActiveRecord::Base
  validates_presence_of :key, :locale
  validates_uniqueness_of :key, :scope => :locale

  def in_english
    translation=Translation.find_by_key_and_locale(self.key, 'en')
    translation ?  translation.value : "#### NO TRANSLATION FOR THIS KEY IN ENGLISH"
  end
end
