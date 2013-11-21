module MesenForms
  module Helpers
    module FormHelper
      def mesen_form_for (object, options = {}, &block)
        options[:builder] = FormBuilder
        options[:url]     = { :action => object.id.nil? ? "create" : "update"}
        options[:html]    = { :class => 'form-horizontal', :id => 'media_file_uploader', :remote => true, :format == 'js' }
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
                                :object_path => object.slug == 'forsiden' ? '/' : (Rails.application.routes.recognize_path(url_for(object), :method => :get) ? url_for(object) : nil),
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
        s = '<svg version="1.1" id="mesen_logo" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="80px" height="20px" viewBox="-18 0 300 70" enable-background="new 0 0 282 70" xml:space="preserve"> <g> <path fill="#003a4e" d="M191.607,43.032c0,4.414-1.467,7.676-4.408,9.783c-2.938,2.102-7.373,3.047-12.602,3.047c-2.99,0-5.516-0.174-7.566-0.529 c-2.059-0.338-3.754-0.783-5.59-1.611v-7.145c1.545,0.945,3.186,1.543,5.422,2.084c2.252,0.541,4.451,0.812,6.621,0.812 c3.049,0,5.158-0.398,6.295-1.217c1.15-0.82,1.721-2.174,1.721-4.055c0-1.217-0.412-2.287-1.234-3.234 c-0.824-0.936-3.172-2.172-7.043-3.727c-3.088-1.236-6.238-3.049-7.928-5.002c-1.68-1.941-2.527-4.596-2.527-7.934 c0-3.197,1.359-5.9,4.094-8.109c2.732-2.213,7.262-3.08,12.066-3.08c2.33,0,4.436,0.191,6.293,0.578 c1.859,0.387,3.172,0.723,3.92,1.025v6.207c-1.574-0.367-3.131-0.705-4.691-0.994c-1.559-0.291-3.23-0.436-4.977-0.436 c-2.49,0-4.291,0.406-5.389,1.178c-1.094,0.783-1.65,1.768-1.65,2.943c0,1.467,0.406,2.588,1.236,3.342 c0.82,0.762,3.23,1.865,7.236,3.338c3.736,1.365,6.744,3.188,8.324,5.284C190.811,37.657,191.607,40.138,191.607,43.032z"/> <g> <rect fill="#003a4e" x="121.771" y="60.722" width="27.844" height="4.371"/> <g> <path fill="#003a4e" d="M132.555,49.058V37.386h12.348v-6.305h-12.348V19.913l15.959,0.02v-6.229l-22.99-0.008 c-2.064,0.016-3.742,1.666-3.762,3.744v37.834h27.846v-6.217H132.555z"/> </g> </g> <g> <rect fill="#003a4e" x="204.209" y="3.907" width="26.775" height="4.355"/> <g> <path fill="#003a4e" d="M232.08,49.069h-17.049V37.386l12.342,0.012v-6.305h-12.342v-11.16h15.953v-6.229h-26.756v37.792h0.004 c0,2.066,1.648,3.742,3.701,3.789h24.146V49.069z"/> </g> </g> <g> <path fill="#003a4e" d="M106.4,13.694h-6.025L84.441,44.077L68.807,13.694h-8.305v37.784h0.006c0,2.088,1.695,3.785,3.789,3.785v0.004h4.057 V31.418l11.912,23.848l4.844,0.008l12.809-23.856v20.135c0.031,2.027,1.668,3.674,3.705,3.721h4.777V13.694z"/> </g> <g> <path fill="#003a4e" d="M274.119,13.704L274.119,13.704c-2.094,0-3.793,1.691-3.793,3.787h-0.002v20.94l-19.877-24.727h-2.584l0,0 c-2.059,0-3.742,1.645-3.789,3.699v37.881h8.023V29.258l20.871,26.026h4.213V13.704H274.119z"/> </g> </g> <g> <path fill="#003a4e" d="M12.859,24.226l-3.043-4.794l-1.123,1.156v3.638H6.263V13.635h2.431v3.893l3.859-3.893h2.958l-4.028,4.114 l4.232,6.477H12.859z"/> <path fill="#003a4e" d="M24.486,24.396c-2.55,0-4.556-1.853-4.556-4.131v-6.63h2.481v6.783c0,1.105,0.867,2.006,2.074,2.006 s2.074-0.901,2.074-2.006v-6.783h2.482v6.63C29.043,22.543,27.054,24.396,24.486,24.396z"/> <path fill="#003a4e" d="M34.211,24.226V13.635h2.465v8.619h4.691v1.972H34.211z"/> <path fill="#003a4e" d="M49.025,15.607v8.619h-2.482v-8.619h-3.11v-1.972h8.704v1.972H49.025z"/> <path fill="#003a4e" d="M10.777,39.896c-2.55,0-4.557-1.853-4.557-4.131v-6.63h2.482v6.783c0,1.104,0.867,2.006,2.074,2.006 s2.074-0.901,2.074-2.006v-6.783h2.482v6.63C15.334,38.043,13.344,39.896,10.777,39.896z"/> <path fill="#003a4e" d="M25.368,39.726l-2.108-4.045h-1.479v4.045h-2.482V29.135h5.117c2.091,0,3.383,1.581,3.383,3.281 c0,1.309-0.781,2.618-2.176,3.06l2.329,4.25H25.368z M24.109,31.158h-2.328v2.567h2.328c0.766,0,1.207-0.612,1.207-1.292 C25.316,31.77,24.857,31.158,24.109,31.158z"/> </g> <g> <path fill="#003a4e" d="M37.199,39.726h-5.117V29.135h4.777c1.955,0,3.535,1.258,3.535,2.975c0,0.952-0.476,1.649-0.951,2.04 c0.662,0.442,1.291,1.344,1.291,2.381C40.734,38.229,39.171,39.726,37.199,39.726z M37.93,32.144c0-0.595-0.425-1.037-1.139-1.037 h-2.244v2.142h2.21c0.799,0,1.155-0.51,1.155-1.105H37.93z M37.012,35.222h-2.465v2.532h2.516c0.612,0,1.19-0.544,1.19-1.19 C38.253,35.867,37.811,35.222,37.012,35.222z"/> <path fill="#003a4e" d="M48.951,35.323v4.402h-2.482v-4.402l-3.705-6.188h2.617l2.33,4.148l2.328-4.148h2.602L48.951,35.323z"/> <path fill="#003a4e" d="M12.291,55.226l-2.109-4.045H8.703v4.045H6.221V44.635h5.117c2.092,0,3.383,1.581,3.383,3.281 c0,1.31-0.781,2.618-2.176,3.06l2.33,4.25H12.291z M11.032,46.658H8.703v2.567h2.329c0.765,0,1.207-0.613,1.207-1.293 C12.239,47.271,11.78,46.658,11.032,46.658z"/> <path fill="#003a4e" d="M32.561,55.226V44.635h7.208v1.972h-4.726v2.143h4.726v1.973h-4.726v2.532h4.726v1.972H32.561z"/> <path fill="#003a4e" d="M48.986,46.606v8.619h-2.481v-8.619h-3.11v-1.972h8.703v1.972H48.986z"/> <g> <path fill="#003a4e" d="M25.102,45.333c0.316-0.369,0.516-0.841,0.516-1.36c0-1.173-0.951-2.125-2.107-2.125 c-1.174,0-2.108,0.952-2.108,2.125c0,0.521,0.196,0.992,0.511,1.361l-3.715,9.892h2.601l0.731-2.227h3.978l0.731,2.227h2.516 L25.102,45.333z M23.51,43.089c0.492,0,0.884,0.391,0.884,0.884c0,0.264-0.127,0.498-0.317,0.662 c-0.154,0.132-0.347,0.222-0.566,0.222c-0.221,0-0.413-0.09-0.566-0.222c-0.191-0.164-0.318-0.398-0.318-0.662 C22.625,43.479,23.017,43.089,23.51,43.089z M22.141,51.163l1.377-4.165l1.377,4.165H22.141z"/> </g> </g> </svg>'.html_safe
      end

      def mesenlogo_invert
        s = '<svg version="1.1" id="mesen_logo_invert" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="80px" height="20px" viewBox="-18 0 300 70" enable-background="new 0 0 282 70" xml:space="preserve"> <g> <path fill="#dddddd" d="M191.607,43.032c0,4.414-1.467,7.676-4.408,9.783c-2.938,2.102-7.373,3.047-12.602,3.047c-2.99,0-5.516-0.174-7.566-0.529 c-2.059-0.338-3.754-0.783-5.59-1.611v-7.145c1.545,0.945,3.186,1.543,5.422,2.084c2.252,0.541,4.451,0.812,6.621,0.812 c3.049,0,5.158-0.398,6.295-1.217c1.15-0.82,1.721-2.174,1.721-4.055c0-1.217-0.412-2.287-1.234-3.234 c-0.824-0.936-3.172-2.172-7.043-3.727c-3.088-1.236-6.238-3.049-7.928-5.002c-1.68-1.941-2.527-4.596-2.527-7.934 c0-3.197,1.359-5.9,4.094-8.109c2.732-2.213,7.262-3.08,12.066-3.08c2.33,0,4.436,0.191,6.293,0.578 c1.859,0.387,3.172,0.723,3.92,1.025v6.207c-1.574-0.367-3.131-0.705-4.691-0.994c-1.559-0.291-3.23-0.436-4.977-0.436 c-2.49,0-4.291,0.406-5.389,1.178c-1.094,0.783-1.65,1.768-1.65,2.943c0,1.467,0.406,2.588,1.236,3.342 c0.82,0.762,3.23,1.865,7.236,3.338c3.736,1.365,6.744,3.188,8.324,5.284C190.811,37.657,191.607,40.138,191.607,43.032z"/> <g> <rect fill="#dddddd" x="121.771" y="60.722" width="27.844" height="4.371"/> <g> <path fill="#dddddd" d="M132.555,49.058V37.386h12.348v-6.305h-12.348V19.913l15.959,0.02v-6.229l-22.99-0.008 c-2.064,0.016-3.742,1.666-3.762,3.744v37.834h27.846v-6.217H132.555z"/> </g> </g> <g> <rect fill="#dddddd" x="204.209" y="3.907" width="26.775" height="4.355"/> <g> <path fill="#dddddd" d="M232.08,49.069h-17.049V37.386l12.342,0.012v-6.305h-12.342v-11.16h15.953v-6.229h-26.756v37.792h0.004 c0,2.066,1.648,3.742,3.701,3.789h24.146V49.069z"/> </g> </g> <g> <path fill="#dddddd" d="M106.4,13.694h-6.025L84.441,44.077L68.807,13.694h-8.305v37.784h0.006c0,2.088,1.695,3.785,3.789,3.785v0.004h4.057 V31.418l11.912,23.848l4.844,0.008l12.809-23.856v20.135c0.031,2.027,1.668,3.674,3.705,3.721h4.777V13.694z"/> </g> <g> <path fill="#dddddd" d="M274.119,13.704L274.119,13.704c-2.094,0-3.793,1.691-3.793,3.787h-0.002v20.94l-19.877-24.727h-2.584l0,0 c-2.059,0-3.742,1.645-3.789,3.699v37.881h8.023V29.258l20.871,26.026h4.213V13.704H274.119z"/> </g> </g> <g> <path fill="#dddddd" d="M12.859,24.226l-3.043-4.794l-1.123,1.156v3.638H6.263V13.635h2.431v3.893l3.859-3.893h2.958l-4.028,4.114 l4.232,6.477H12.859z"/> <path fill="#dddddd" d="M24.486,24.396c-2.55,0-4.556-1.853-4.556-4.131v-6.63h2.481v6.783c0,1.105,0.867,2.006,2.074,2.006 s2.074-0.901,2.074-2.006v-6.783h2.482v6.63C29.043,22.543,27.054,24.396,24.486,24.396z"/> <path fill="#dddddd" d="M34.211,24.226V13.635h2.465v8.619h4.691v1.972H34.211z"/> <path fill="#dddddd" d="M49.025,15.607v8.619h-2.482v-8.619h-3.11v-1.972h8.704v1.972H49.025z"/> <path fill="#dddddd" d="M10.777,39.896c-2.55,0-4.557-1.853-4.557-4.131v-6.63h2.482v6.783c0,1.104,0.867,2.006,2.074,2.006 s2.074-0.901,2.074-2.006v-6.783h2.482v6.63C15.334,38.043,13.344,39.896,10.777,39.896z"/> <path fill="#dddddd" d="M25.368,39.726l-2.108-4.045h-1.479v4.045h-2.482V29.135h5.117c2.091,0,3.383,1.581,3.383,3.281 c0,1.309-0.781,2.618-2.176,3.06l2.329,4.25H25.368z M24.109,31.158h-2.328v2.567h2.328c0.766,0,1.207-0.612,1.207-1.292 C25.316,31.77,24.857,31.158,24.109,31.158z"/> </g> <g> <path fill="#dddddd" d="M37.199,39.726h-5.117V29.135h4.777c1.955,0,3.535,1.258,3.535,2.975c0,0.952-0.476,1.649-0.951,2.04 c0.662,0.442,1.291,1.344,1.291,2.381C40.734,38.229,39.171,39.726,37.199,39.726z M37.93,32.144c0-0.595-0.425-1.037-1.139-1.037 h-2.244v2.142h2.21c0.799,0,1.155-0.51,1.155-1.105H37.93z M37.012,35.222h-2.465v2.532h2.516c0.612,0,1.19-0.544,1.19-1.19 C38.253,35.867,37.811,35.222,37.012,35.222z"/> <path fill="#dddddd" d="M48.951,35.323v4.402h-2.482v-4.402l-3.705-6.188h2.617l2.33,4.148l2.328-4.148h2.602L48.951,35.323z"/> <path fill="#dddddd" d="M12.291,55.226l-2.109-4.045H8.703v4.045H6.221V44.635h5.117c2.092,0,3.383,1.581,3.383,3.281 c0,1.31-0.781,2.618-2.176,3.06l2.33,4.25H12.291z M11.032,46.658H8.703v2.567h2.329c0.765,0,1.207-0.613,1.207-1.293 C12.239,47.271,11.78,46.658,11.032,46.658z"/> <path fill="#dddddd" d="M32.561,55.226V44.635h7.208v1.972h-4.726v2.143h4.726v1.973h-4.726v2.532h4.726v1.972H32.561z"/> <path fill="#dddddd" d="M48.986,46.606v8.619h-2.481v-8.619h-3.11v-1.972h8.703v1.972H48.986z"/> <g> <path fill="#dddddd" d="M25.102,45.333c0.316-0.369,0.516-0.841,0.516-1.36c0-1.173-0.951-2.125-2.107-2.125 c-1.174,0-2.108,0.952-2.108,2.125c0,0.521,0.196,0.992,0.511,1.361l-3.715,9.892h2.601l0.731-2.227h3.978l0.731,2.227h2.516 L25.102,45.333z M23.51,43.089c0.492,0,0.884,0.391,0.884,0.884c0,0.264-0.127,0.498-0.317,0.662 c-0.154,0.132-0.347,0.222-0.566,0.222c-0.221,0-0.413-0.09-0.566-0.222c-0.191-0.164-0.318-0.398-0.318-0.662 C22.625,43.479,23.017,43.089,23.51,43.089z M22.141,51.163l1.377-4.165l1.377,4.165H22.141z"/> </g> </g> </svg>'.html_safe
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
