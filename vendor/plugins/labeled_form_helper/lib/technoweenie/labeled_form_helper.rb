module Technoweenie #:nodoc:
  module LabeledFormHelper
    # Creates a form and a scope around a model object like #form_for.  However, form tags are labeled and rendered inside a <p>.
    #   <% form_for :person, @person, :url => { :action => "update" } do |f| %>
    #     First name: <%= f.text_field :first_name %>
    #   <% end %>
    # 
    #     <form action="update">
    #       <p><label for="person_first_name">First Name</label><br /><input type="text" id="person_first_name" name="person[first_name]" /></p>
    def labeled_form_for(object_name, object, options = {}, &proc)
      form_for(object_name, object, options.merge(:builder => LabeledFormBuilder), &proc)
    end

    # Creates a scope around a specific model object like form_for, but doesn't create the form tags themselves.  However, form 
    # tags are labeled and rendered inside a <p>.
    def labeled_fields_for(object_name, object, options = {}, &proc)
      fields_for(object_name, object, {:builder => LabeledFormBuilder}, &proc)
    end

    # Works like form_remote_tag, but uses labeled_form_for semantics.
    def labeled_form_remote_for(object_name, object, options = {}, &proc)
      form_remote_for(object_name, object, options.merge(:builder => LabeledFormBuilder), &proc)
    end
    alias_method :labeled_remote_form_for, :labeled_form_remote_for

    # Returns a label tag that points to a specified attribute (identified by +method+) on an object assigned to a template
    # (identified by +object+).  Additional options on the input tag can be passed as a hash with +options+.  An alternate
    # text label can be passed as a 'text' key to +options+.
    # Example (call, result).
    #   label_for('post', 'category')
    #     <label for="post_category">Category</label>
    # 
    #   label_for('post', 'category', 'text' => 'This Category')
    #     <label for="post_category">This Category</label>
    def label_for(object_name, method, options = {})
      ActionView::Helpers::InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_label_tag(options)
    end

    # Creates a label tag.
    #   label_tag('post_title', 'Title')
    #     <label for="post_title">Title</label>
    def label_tag(name, text, options = {})
      content_tag('label', text, { 'for' => name }.merge(options.stringify_keys))
    end
  end

  module LabeledInstanceTag #:nodoc:
    def to_label_tag(options = {})
      options = options.stringify_keys
      add_default_name_and_id(options)
      options.delete('name')
      options['for'] = options.delete('id')
      content_tag 'label', options.delete('text') || @method_name.humanize, options
    end
  end

  module FormBuilderMethods #:nodoc:
    def label_for(method, options = {})
      @template.label_for(@object_name, method, options.merge(:object => @object))
    end
  end

  class LabeledFormBuilder < ActionView::Helpers::FormBuilder #:nodoc:
    (ActionView::Helpers::FormHelper.instance_methods - %w(label_for hidden_field check_box radio_button form_for fields_for)).each do |selector|
      src = <<-end_src
        def #{selector}(method, options = {})
          @template.content_tag('p', label_for(method) + "<br />" + super)
        end
      end_src
      class_eval src, __FILE__, __LINE__
    end

    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      @template.content_tag('p', label_for(method) + "<br />" + super)
    end

    def hidden_field(method, options={})
      super
    end

    def radio_button(method, tag_value, options = {})
      @template.content_tag('p', label_for(method) + "<br />" + super)
    end

    def fields_for(object_name, object, builder = self.class, &proc)
      @template.labeled_fields_for(object_name, object, builder, &proc)
    end
  end
end