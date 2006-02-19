module Admin::SectionsHelper
  def section_label(section)
    ("(system) " if section.system?).to_s + section.filename
  end

  def options_from_sections_for_select(sections, selected = nil)
    '<option value="0">-- default --</option>' +
    options_for_select(sections.sort_by { |s| s.filename }.inject([]) { |options, section| options << [section_label(section), section.id.to_s] }, selected)
  end
end
