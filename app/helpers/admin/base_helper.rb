module Admin::BaseHelper
  def options_from_templates_for_select(templates, selected = nil)
    '<option value="-">-- default --</option>' +
    options_for_select(templates.inject([]) { |options, template| options << template.basename.to_s.split('.').first }, selected.to_s)
  end
end
