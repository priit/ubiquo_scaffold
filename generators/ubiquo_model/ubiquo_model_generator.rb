class UbiquoModelGenerator < Rails::Generator::NamedBase
  
  # Abbreviation of Title or name. Contains 'title', 'name', or nil depending on attributes
  attr_reader   :ton, :has_published_at, :field_translations, :locale_for_template
  
  default_options :skip_timestamps => false, :skip_migration => false, :skip_fixture => false

  def manifest
    record do |m|
      # TODO: Move this to yaml file if if grows to big overtime
      @field_translations = { 
        'title' => { :ca => 'Títol', :es => 'Título'},
        'name' => { :ca => 'Nom', :es => 'Nombre'},
        'published_at' => { :ca => 'Data de publicació', :es => 'Fecha de publicación' }
      }
      
      @ton = attributes.map(&:name).find{|a|a.to_s == 'title' || a.to_s == 'name'}
      @has_published_at = !attributes.map(&:name).find{|a|a.to_s == "published_at"}.nil?
      
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)

      for locale in Ubiquo.supported_locales
        m.directory(File.join('config/locales', locale, 'models'))
      end

      # Model class, unit test, and fixtures.
      m.template 'model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'unit_test.rb',  File.join('test/unit', class_path, "#{file_name}_test.rb")

      unless options[:skip_fixture] 
       	m.template 'fixtures.yml',  File.join('test/fixtures', "#{table_name}.yml")
      end
      
      for locale in Ubiquo.supported_locales
        m.template(
          "model-#{locale}.yml",
          File.join('config/locales', locale, 'models', "#{file_name}.yml")
        ) unless locale == 'en'
      end
      
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--skip-fixture",
             "Don't generation a fixture file for this model") { |v| options[:skip_fixture] = v}
      opt.on("--versionable",
             "Creates a versionable model") { |v| options[:versionable] = v}
      opt.on("--max-versions-amount [N]", Integer,
             "Set max versions amount for versionable models") { |v| options[:versions_amount] = v}
      opt.on("--translatable f1,f2...", Array,
        "Creates a translatable model") { |v| options[:translatable] = v}
    end
end

