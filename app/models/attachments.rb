class Attachments < Array
  attr_accessor :theme

  def write(relative_path, data = nil)
    full_path = self[relative_path]
    unless data.nil?
      path, filename = full_path.split
      FileUtils.mkdir_p path.to_s
      File.open(full_path, 'wb') { |f| f.write data }
    end
    full_path
  end
end