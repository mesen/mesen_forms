module MesenForms
  class Engine < ::Rails::Engine
    initializer 'mesen_forms.initialize' do
      config.to_prepare do
        ActiveSupport.on_load(:action_view) do
          include MesenForms::Helpers::FormHelper
          
          ::ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
            html_tag
          end
        end
      end
    end
  end
end