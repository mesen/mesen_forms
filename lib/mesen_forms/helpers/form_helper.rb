module MesenForms
  module Helpers
    module FormHelper
      def mesen_form_for (object, options = {}, &block)
        options[:builder] = FormBuilder
        options[:url]     = { :action => object.id.nil? ? "create" : "update"}
        options[:html]    = { :class => 'form-horizontal', :id => 'media_file_uploader'}
        form_for(object, options, &block)
      end

      def menu_link_to(title,url)
        content_tag(:li, content_tag(:a, I18n.t(title, :scope => [:layouts, :admin]), :href => url), :class => ('active' if (request.original_fullpath.split('/')[2] == url.split('/')[2])))
      end
  
      def submenu_link_to(title, url)
        content_tag(:li, content_tag(:a, I18n.t(title, :scope => [:admin, controller_name]), :href => url), :class => ('active' if current_page?(url)))
      end
  
      # If the user is deleted who updated this object: updated_by =nil
      def update_info(object)
        who_when object.updated_by, object.updated_at
      end
  
      # If the user is deleted who created this object: created_by =nil
      def create_info(object)
        who_when object.created_by, object.created_at
      end
  
      def who_when(user_id,at)
        str = relative_or_absolute_date(at)
        if user_id
          begin
            user_obj = User.find(user_id)
            user = user_obj.fullname
          rescue
            user_obj = nil
            user = nil
          end
          if !user.blank?
            str = I18n.t(:created_at_by, :scope => [:layouts, :admin], :time => str, :username => user)
          end
        end
        str
      end
  
      # Information about an object:
      # object_path: Addresse, link to show the object 
      # objects_string: String for: Vis alle 'objects_string'
      def meta_info(object, options = {})
        # defaults
        begin
          object_path = url_for(object)
        rescue 
          object_path = options[:object_path]
        end

        if options[:admin_path]
          admin_path = options[:admin_path]
        else
          admin_path = url_for([:admin, object])
        end

        options.reverse_merge!({:show_delete => true,
                                :title_column => 'title',
                                :admin_path => admin_path,
                                :object_path => object.slug == 'forsiden' ? '/' : (Rails.application.routes.recognize_path(object_path, :method => :get) ? object_path : nil),
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
          content_tag(:tr) do
            content_tag(:td, I18n.t(:address, :scope => [:layouts, :admin]))+
            content_tag(:td, link_to(options[:object_path], options[:object_path], :target => '_blank'))
          end+
          if options[:show_delete]
            content_tag(:tr) do
              content_tag(:td, I18n.t(:delete, :scope => [:layouts, :admin]))+
              content_tag(:td, link_to(I18n.t(:delete, :scope => [:layouts, :admin]), options[:admin_path], :data => { :confirm => I18n.t(:delete_confirmation, :scope => [:layouts, :admin], :title => object.instance_eval(options[:title_column]))}, :method => :delete, :class => "btn btn-danger btn-mini"))
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
  
      def link_to_add_fields(name, f, association, renderform)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
          if !renderform.nil?
            render(renderform, f: builder)
          else
            render(association.to_s.singularize + "_fields", f: builder)
          end
        end
        link_to(name, '#', class: "add_fields btn", data: {id: id, fields: fields.gsub("\n", "")})
      end

      def mesenlogo
        s = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Layer_1" x="0px" y="0px" width="77px" height="20px" viewBox="0 0 46.095 12.728" enable-background="new 0 0 46.095 12.728" xml:space="preserve" xmlns:xml="http://www.w3.org/XML/1998/namespace"><g><g><polyline points="6.225,8.805 1.402,0.899 1.188,0.928 1.188,11.6 2.345,11.6 2.345,4.444 6.096,10.525 6.356,10.525     10.108,4.444 10.108,11.6 11.263,11.6 11.263,0.928 11.048,0.899 6.225,8.805   "/></g><path d="M13.447,11.6V1.101h6.144v1.03h-5v3.624h4.499v1.033h-4.499v3.781h5V11.6H13.447z"/><path d="M23.917,11.772c-1.19,0-2.121-0.372-3.036-0.975l0.558-1.002c0.804,0.571,1.719,0.932,2.536,0.932   c1.347,0,1.977-0.891,1.977-1.834c0-0.917-0.357-1.462-2.078-2.221c-1.818-0.802-2.492-1.619-2.492-2.88   c0-1.517,1.29-2.865,3.208-2.865c0.888,0,1.733,0.302,2.336,0.716l-0.516,0.976c-0.516-0.373-1.204-0.645-1.891-0.645   c-1.319,0-1.991,0.802-1.991,1.761c0,0.731,0.5,1.318,1.79,1.905c2.19,0.988,2.807,1.719,2.807,3.124   C27.124,10.467,25.735,11.772,23.917,11.772z"/><path d="M34.501,5.755v1.033h-4.498v3.781h4.998V11.6h-6.143V5.755H34.501z"/><path d="M28.505,1.937l5.991-1.368l0.231,1.005l-5.993,1.369L28.505,1.937z"/><path d="M45.045,11.799l-6.819-8.163V11.6H37.08V0.958l0.23-0.058l6.73,8.037V1.101h1.146v10.656L45.045,11.799z"/></g></svg>'.html_safe
      end

      def mesenlogo_invert
        s = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Layer_1" x="0px" y="0px" width="77px" height="20px" viewBox="0 0 46.095 12.728" enable-background="new 0 0 46.095 12.728" xml:space="preserve" xmlns:xml="http://www.w3.org/XML/1998/namespace"><g><g><polyline points="6.225,8.805 1.402,0.899 1.188,0.928 1.188,11.6 2.345,11.6 2.345,4.444 6.096,10.525 6.356,10.525     10.108,4.444 10.108,11.6 11.263,11.6 11.263,0.928 11.048,0.899 6.225,8.805   "/></g><path d="M13.447,11.6V1.101h6.144v1.03h-5v3.624h4.499v1.033h-4.499v3.781h5V11.6H13.447z"/><path d="M23.917,11.772c-1.19,0-2.121-0.372-3.036-0.975l0.558-1.002c0.804,0.571,1.719,0.932,2.536,0.932   c1.347,0,1.977-0.891,1.977-1.834c0-0.917-0.357-1.462-2.078-2.221c-1.818-0.802-2.492-1.619-2.492-2.88   c0-1.517,1.29-2.865,3.208-2.865c0.888,0,1.733,0.302,2.336,0.716l-0.516,0.976c-0.516-0.373-1.204-0.645-1.891-0.645   c-1.319,0-1.991,0.802-1.991,1.761c0,0.731,0.5,1.318,1.79,1.905c2.19,0.988,2.807,1.719,2.807,3.124   C27.124,10.467,25.735,11.772,23.917,11.772z"/><path d="M34.501,5.755v1.033h-4.498v3.781h4.998V11.6h-6.143V5.755H34.501z"/><path d="M28.505,1.937l5.991-1.368l0.231,1.005l-5.993,1.369L28.505,1.937z"/><path d="M45.045,11.799l-6.819-8.163V11.6H37.08V0.958l0.23-0.058l6.73,8.037V1.101h1.146v10.656L45.045,11.799z"/></g></svg>'.html_safe
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
