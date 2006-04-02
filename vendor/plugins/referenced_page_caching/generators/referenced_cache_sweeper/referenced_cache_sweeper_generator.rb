class ReferencedCacheSweeperGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    runtime_args << 'reference' if runtime_args.empty?
    super
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Sweeper"

      # Controller, helper, views, and test directories.
      m.directory File.join('app/models', class_path)

      m.template "sweeper.rb", File.join('app/models',
                                          class_path,
                                         "#{file_name}_sweeper.rb")
    end
  end
end
