module MesenForms
  module Helpers
    module FormHelper
      def mesen_form_for (object, options = {}, &block)
        options[:builder] = FormBuilder
        options[:url]     = { :action => object.id.nil? ? "create" : "update"}
        options[:html]    = {:class => 'form-horizontal'}
        form_for(object, options, &block)
      end

      def menu_link_to(title,url)
        content_tag(:li, content_tag(:a, I18n.t(title, :scope => [:layouts, :admin]), :href => url), :class => ('active' if (request.original_fullpath.split('/')[2] == url.split('/')[2])))
      end
  
      def submenu_link_to(title, url)
        content_tag(:li, content_tag(:a, I18n.t(title, :scope => [:admin, controller_name]), :href => url), :class => ('active' if current_page?(url)))
      end
  
      def update_info(object)
        who_when object.updated_by, object.updated_at
      end
  
      def create_info(object)
        who_when object.created_by, object.created_at
      end
  
      def who_when(user_id,at)
        str = relative_or_absolute_date(at)
        if user_id
          user_obj = User.find(user_id)
          user = user_obj.fullname
          if !user.blank?
            str = I18n.t(:created_at_by, :scope => [:layouts, :admin], :time => str, :username => user)
          end
        end
        str
      end
  
      def meta_info(object, options = {})
        # defaults
        options.reverse_merge!({:show_delete => true,
                                :title_column => 'title',
                                :admin_path => url_for([:admin, object]),
                                :object_path => object.slug == 'forsiden' ? '/' : (url_for(object) ? url_for(object) : false),
                                :objects_string => I18n.t(object.class.name.underscore.pluralize, :scope => [:activerecord,:models]),
                                :edit_path => url_for([:admin, object.class])})
  
        content_tag(:table, :class => 'table table-condensed meta-info') do
          content_tag(:tr) do
            content_tag(:td, I18n.t(:last_updated, :scope => [:layouts, :admin])) +
            content_tag(:td, update_info(object))
          end+
          content_tag(:tr) do
            content_tag(:td, I18n.t(:created, :scope => [:layouts, :admin])) +
            content_tag(:td, create_info(object))
          end+
          if options[:object_path]
            content_tag(:tr) do
              content_tag(:td, I18n.t(:address, :scope => [:layouts, :admin]))+
              content_tag(:td, link_to(options[:object_path], options[:object_path], :target => '_blank'))
            end
          end+
          if options[:show_delete]
            content_tag(:tr) do
              content_tag(:td, I18n.t(:delete, :scope => [:layouts, :admin]))+
              content_tag(:td, link_to(I18n.t(:delete, :scope => [:layouts, :admin]), options[:admin_path], :confirm => I18n.t(:delete_confirmation, :scope => [:layouts, :admin], :title => object.instance_eval(options[:title_column])), :method => :delete, :class => "btn btn-danger btn-mini"))
            end
          end
        end+
        link_to(I18n.t(:show_all, :scope => [:layouts, :admin]) + ' ' + options[:objects_string], options[:edit_path], :class => "btn")
      end
  
      def publish_status(object)
        if ((defined? object.is_published) == nil) || object.is_published
          if ((defined? object.is_published) != nil and object.is_published and (defined? object.published_at) != nil and object.published_at.nil? == false and object.published_at > Time.now)
            status = t :on_hold, :scope => [:layouts, :admin]
            status_class = 'info'
          else
            status = t :published, :scope => [:layouts, :admin]
            status_class = 'success'
          end
        else
          status = t :draft, :scope => [:layouts, :admin]
          status_class = 'warning'
        end
        content_tag(:span, status, :class => 'label label-'+status_class)
      end
  
      def display_errors object
        if object.errors.any?
          content_tag :div, :class => 'alert span7 alert-error' do
            cc = content_tag(:a, "&times;".html_safe, href: "#", class: "close", data: {dismiss: "alert"}).html_safe
            cc << content_tag(:h3, I18n.t('activerecord.errors.template.header', :count => object.errors.size, :model => t(object.class.to_s.underscore))).html_safe
            cc << content_tag(:ul) do
              object.errors.full_messages.reduce('') { |ccc, message| ccc << content_tag(:li, message) }.html_safe
            end
          end
        end
      end
  
      def bootstrap_flash(flash)
        flash.map do |k, f|
          container_class = "alert span7 alert-"
          container_class << bootstrap_notice_container_class(k)
          content_tag :div, class: 'row' do
            content_tag :div, class: container_class, data: { alert: "alert" } do
              content_tag(:a, "&times;".html_safe, href: "#", class: "close", data: {dismiss: "alert"}) +
              f
            end
          end
        end.join(" ").html_safe
      end
  
      def link_to_add_fields(name, f, association)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
          render(association.to_s.singularize + "_fields", f: builder)
        end
        link_to(name, '#', class: "add_fields btn", data: {id: id, fields: fields.gsub("\n", "")})
      end
  
      private
        def bootstrap_notice_container_class(flash_type)
          if flash_type.to_s == 'notice'
            r = "notice"
          else
            r = "error"
          end
          r
        end
    end
  end
end
