class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.string   :key
      t.text     :value
      t.string  :locale
    end
    add_index :translations, [:locale, :key]

  end

  def self.down
    drop_table :translations
  end
end
