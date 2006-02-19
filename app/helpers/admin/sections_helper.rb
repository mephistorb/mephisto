module Admin::SectionsHelper
  def options_from_sections_for_select(sections, selected = nil)
    '<option value="0">-- default --</option>' +
    options_for_select(sections.sort_by { |s| s.filename }.inject([]) { |options, section| options << [section.name, section.id.to_s] }, selected.to_s)
  end
end
