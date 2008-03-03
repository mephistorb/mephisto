module Admin::SettingsHelper
  def spam_engine_settings_for(klass_name)
    if @site.spam_detection_engine == klass_name then
      style = nil
    else
      style = "display:none"
    end

    content_tag(:div, klass_name.constantize.settings_template(@site), :id => klass_name.split("::").last + "Settings", :class => "settings", :style => style)
  end
end
