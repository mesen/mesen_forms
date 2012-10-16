module MesenForms
  class FormBuilder < ::ActionView::Helpers::FormBuilder
    delegate :content_tag, :tag, :button_tag, :submit_tag, :link_to, :current_user, :link_to_add_fields, :render, :to => :@template
    
    %w[text_area text_field email_field url_field password_field collection_select].each do |method_name|
      define_method(method_name) do |attribute, *options|
        *old_opts = *options
        opts = options.extract_options!
        if opts[:skip_label]
          super(attribute, *old_opts)
        else
          control_group do
            label(attribute, class: 'control-label')+
            controls do
              if method_name == 'text_area' && opts[:cktext]
                cktext_area(attribute.to_sym, :toolbar => opts[:cktext], :rows => (opts[:rows] ?  opts[:rows] : 5), :width => 322, :height => (opts[:height] ? opts[:height] : 200), :js_content_for => :ckeditor_js)
              else
                super(attribute, *old_opts)
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
          if(defined?object.instance_eval(attribute.to_s) && !object.instance_eval(attribute.to_s).blank?)
            @template.image_tag(object.instance_eval(attribute.to_s).url(:thumb))
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
          content_tag(:div, :class => 'well fields-wrapper') do
            fields_for(attribute) do |field|
              render(attribute.to_s.singularize + '_fields', :f => field)
            end+
            content_tag(:div, I18n.t("no_" + attribute.to_s, :scope => [:layouts, :admin]).html_safe, class: ('hidden' if object.instance_eval(attribute.to_s).any?))
          end+
          link_to_add_fields(I18n.t('add_' + attribute.to_s.singularize, :scope => [:layouts, :admin]), self, attribute)+
          if options[:help]
            help_block options[:help]
          end
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
          elsif (!defined? object.is_published) && !object.id
            pub_btn_txt = I18n.t :create, :scope => [:layouts, :admin]
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

  def localized_text_field(attribute, options={})
    default_attr  = attribute.to_s<<'_'<<I18n.default_locale.to_s
    locales       = ['en','de']
    active_locale = 'en'    
    control_group do
      label(default_attr, class: 'control-label')+
      controls do
        tabbable('pull-right') do
          locale_tab_links(attribute, locales, active_locale)+
          locale_tab_text_fields(attribute, locales, active_locale, options)
        end+
        text_field(default_attr.to_sym, :class => 'input-large', :skip_label => true)+
        if options[:help]
          help_block options[:help]
        end
      end
    end
  end

  def locale_tab_text_fields attr_base, locales, active_locale, options
    content_tag :div, class: 'tab-content' do
      locales.map do |locale|
        unless locale == I18n.default_locale
          locale_tab_text_field attr_base, locale, (true if active_locale == locale), options
        end
      end.join.html_safe
    end
  end

  def locale_tab_text_field attr_base, locale, active = false, options
    attribute = attr_base.to_s + '_' + locale
    dom_class = 'tab-pane'<< (active ? ' active' : '')
    content_tag :div, class: dom_class, id: 'pane_'+object.class.name.downcase+'_'+attribute + '_'+object.id.to_s do
      text_field(attribute.to_sym, :class => 'input-large', :skip_label => true)
    end
  end

  def localized_text_area(attribute, options={})
    default_attr  = attribute.to_s<<'_'<<I18n.default_locale.to_s
    locales       = ['en','de']
    active_locale = 'en'
    control_group do
      label(default_attr, class: 'control-label')+
      controls do
        tabbable('pull-right') do
          locale_tab_links(attribute, locales, active_locale)+
          locale_tab_text_areas(attribute, locales, active_locale, options)
        end+
        if options[:cktext]
          cktext_area(default_attr.to_sym, :rows => (options[:rows] ?  options[:rows] : 5), :toolbar => options[:cktext], :width => 322, :height => (options[:height] ? options[:height] : 200), :js_content_for => :ckeditor_js)
        else
          text_area(default_attr.to_sym, :rows => (options[:rows] ?  options[:rows] : 5), :class => 'input-large', :skip_label => true)
        end+
        if options[:help]
          help_block options[:help]
        end
      end
    end
  end

  def tabbable align_class = nil
    content_tag(:div, class: 'tabbable tabs-right ' << align_class.to_s) do
      yield
    end
  end

  def locale_tab_links attr_base, locales, active_locale
    content_tag :ul, class: 'nav nav-tabs' do
      locales.map do |locale|
        unless locale == I18n.default_locale
          locale_tab_link(attr_base, locale, (true if active_locale == locale))
        end
      end.join.html_safe
    end
  end

  def locale_tab_link attr_base, locale, active = false
    locale_link = '#pane_'+object.class.name.downcase+'_'+attr_base.to_s+'_'+locale+'_'+object.id.to_s

    content_tag :li, class: ('active' if active) do
      content_tag :a, href: locale_link, data: {:toggle => 'tab'} do
        I18n.t locale.to_sym, :scope => [:layouts, :admin]
      end
    end
  end 

  def locale_tab_text_areas attr_base, locales, active_locale, options
    content_tag :div, class: 'tab-content' do
      locales.map do |locale|
        unless locale == I18n.default_locale
          locale_tab_text_area attr_base, locale, (true if active_locale == locale), options
        end
      end.join.html_safe
    end
  end

  def locale_tab_text_area attr_base, locale, active = false, options
    attribute = attr_base.to_s + '_' + locale
    dom_class = 'tab-pane'<< (active ? ' active' : '')
    content_tag :div, class: dom_class, id: 'pane_'+object.class.name.downcase+'_'+attribute+'_'+object.id.to_s do
      if options[:cktext]
        cktext_area(attribute.to_sym, :toolbar => options[:cktext], :rows => (options[:rows] ?  options[:rows] : 5), :width => 322, :height => (options[:height] ? options[:height] : 200), :js_content_for => :ckeditor_js)
      else
        text_area attribute.to_sym, :rows => (options[:rows] ?  options[:rows] : 5), :class => 'input-large', :skip_label => true
      end
    end
  end
end
end