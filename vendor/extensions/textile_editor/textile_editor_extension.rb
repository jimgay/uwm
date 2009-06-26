begin
  # Radiant 0.8.0 / Rails 2.3
  require_dependency 'application_controller'
rescue MissingSourceFile
  # pre Radiant 0.8.0 / pre Rails 2.3
  require_dependency 'application'
end

class TextileEditorExtension < Radiant::Extension
  version "2.0"
  description "Places a toolbar above the textarea when Textile is the current input filter."
  url "http://yourwebsite.com/textile_editor"
  
  define_routes do |map|
    map.connect 'admin/textile_editor/:action', :controller => 'admin/textile_editor'
  end
  
  def activate
    ApplicationController.send :include, TextileEditor::Ext::ApplicationController
    [Admin::PagesController, Admin::SnippetsController].each do |c| 
      c.send :before_filter, :include_textile_editor_assets
    end
    [:pages, :snippet].each do |controller|
      admin.send(controller).edit.add :main, 'admin/pages/link_popup'
      admin.send(controller).edit.add :main, 'admin/pages/image_popup'
    end
    Admin::PagesHelper.send :include, TextileEditor::Ext::Admin::PagesHelper
  end
  
  def deactivate
  end
  
end