module Admin::SectionsHelper
  def options_from_templates_for_select(template, selected = nil)
    '<option value="0">-- default --</option>' +
    options_for_select(template.sort_by { |s| s.filename }.inject([]) { |options, template| options << [template.filename, template.id.to_s] }, selected.to_s)
  end
end
