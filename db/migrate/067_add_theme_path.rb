class AddThemePath < ActiveRecord::Migration
  def self.up
    add_column "sites", "current_theme_path", :string
    execute "UPDATE sites SET current_theme_path = 'current'"
    Dir[RAILS_PATH + 'themes' + 'site-*'].each do |site|
      Dir[site + '/other/*'].each do |theme|
        theme_base = File.basename(theme)
        next if File.exist?(File.join(site, theme_base))
        say_with_time "Moved #{theme_base} to #{site}..." do
          mv theme, site
        end
      end
    end
  end

  def self.down
    remove_column "sites", "current_theme_path"
  end
end
