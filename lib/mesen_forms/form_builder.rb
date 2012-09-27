module MesenForms
  class FormBuilder < ::ActionView::Helpers::FormBuilder
    delegate :content_tag, :tag, :button_tag, :submit_tag, :link_to, :current_user, :link_to_add_fields, :fields_for, :render, :to => :@template
    
    %w[text_area text_field email_field url_field password_field collection_select].each do |method_name|
      define_method(method_name) do |attribute, *options|
        opts = options.extract_options!
        if opts[:skip_label]
          super(attribute, *options)
        else
          control_group do
            label(attribute, class: 'control-label')+
            controls do
              if method_name == 'text_area' && opts[:cktext]
                cktext_area(attribute.to_sym, :toolbar => opts[:cktext], :rows => (opts[:rows] ?  opts[:rows] : 5), :width => 322, :height => (opts[:height] ? opts[:height] : 200), :js_content_for => :ckeditor_js)
              else
                super(attribute, *options)
              end+
              if opts[:help]
                help_block opts[:help]
              end
            end
          end
        end
      end
    end

    def errors options={}
      if object.errors.any?
        content_tag :div, :class => 'alert span7 alert-error' do
          content_tag(:a, "&times;".html_safe, href: "#", class: "close", data: {dismiss: "alert"})+
          content_tag(:h3, I18n.t('activerecord.errors.template.header', :count => object.errors.size, :model => I18n.t(object.class.to_s.underscore, :scope => [:activerecord, :models])))+
          content_tag(:ul) do
            object.errors.full_messages.reduce('') { |ccc, message| ccc << content_tag(:li, message) }.html_safe
          end
        end
      end
    end

    def image_upload(attribute, options={})
      control_group do
        label(attribute, class: 'control-label')+
        controls do
          if(defined?object[attribute] && !object[attribute].blank?)
            @template.image_tag.(object.instance_eval(attribute).url(:thumb))
          end+
          tag('br')+
          file_field(attribute)+
          if options[:help]
            help_block options[:help]
          end
        end
      end
    end

    def nested_form(attribute, options={})
      control_group do
        label(attribute, class: 'control-label')+
        controls do
          content_tag :div, :class => 'well fields-wrapper' do
            fields_for attribute do |field|
              render(attribute.to_s.singularize + '_fields', :f => field)
            end
            content_tag :div, :class => ('hidden' if object.instance_eval(attribute).any?) do
              'no_' + I18n.t(object.class.to_s.underscore, :scope => [:activerecord, :models])
            end
          end
          link_to_add_fields(I18n.t('add_' + attribute.to_s.singularize, :scope => [:layouts, :admin]), self, attribute)
        end
      end
    end

    def datetime_select(attribute, options={})
      control_group do
        label(attribute, class: 'control-label')+
        controls do
          super+
          if options[:help]
            help_block options[:help]
          end
        end
      end
    end

    def map_input(attribute, options={})
      control_group do
        label(attribute, class: 'control-label')+
        controls do
          hidden_field(:lat).html_safe+
          hidden_field(:lng).html_safe
        end
      end
    end

    def control_group
      content_tag(:div, class: 'control-group') do
        yield
      end
    end

    def controls options={}
      content_tag :div, class: 'controls' do
        yield
      end
    end

    def help_block string
      content_tag :p, class: 'help-block' do
        I18n.t string, :scope => [:activerecord, :help_strings, @template.controller_name.singularize]
      end
    end

    def form_actions options={}
      content_tag :div, :class => 'form-actions' do
        if current_user
          if (defined? object.is_published) && (object.id) && (object.is_published == true)
            pub_btn_txt = I18n.t :save_changes, :scope => [:layouts, :admin]
          elsif (!defined? object.is_published) && object.id
            pub_btn_txt = I18n.t :save_changes, :scope => [:layouts, :admin]
          else
            pub_btn_txt = I18n.t :publish, :scope => [:layouts, :admin]
          end
          c = submit_tag pub_btn_txt, :name => 'submit', :class => 'btn btn-primary'
          c << ' '
          # you can not save a published object as a draft
          if (defined? object.is_published) && ((object.id.nil? == true))
            c << submit_tag(I18n.t(:save_as_draft, :scope => [:layouts, :admin]), :name => 'draft', :class => 'btn')
          elsif (defined? object.is_published) && (object.is_published == false) && (object.id.nil? == false)
            c << submit_tag(I18n.t(:save_changes_in_draft, :scope => [:layouts, :admin]), :name => 'draft', :class => 'btn')
          end
          c
        else
          if (object.id.nil? == true)
            pub_btn_txt = I18n.t :save, :scope => [:layouts, :admin]
          else
            pub_btn_txt = I18n.t :save_changes, :scope => [:layouts, :admin]
          end
          c = submit_tag pub_btn_txt, :name => 'draft', :class => 'btn btn-primary'
        end
        # c += submit_tag I18n.t(:preview, :scope => [:layouts, :admin]), :name => 'preview', :class => 'btn pull-right'
      end
    end
  end
end
