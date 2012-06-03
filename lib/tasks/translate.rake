namespace :translations  do
  namespace :import do
    desc 'Populate the locales and translations from  Locale YAML files(en) to translations table, overwrite by set YML_FILES'
    task :from_yml => :environment do
      yaml_files = ENV['YML_FILES'] ? ENV['YML_FILES'].split(',') : ['config/locales/en.yml', 'config/locales/it.yml']
      yaml_files.each do |file|
        Translations::I18nUtil.load_from_yml file
      end
    end
  end

  namespace :export do
    desc 'export keys from translations table to yml files'
    task :to_yml => :environment do
      yaml_path = "#{RAILS_ROOT}/config/locales/"
      for locale in Locale.all
        Translations::I18nUtil.export_to_yml(locale, yaml_path)
      end
    end
  end
end
