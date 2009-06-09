require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/pages/edit" do
  dataset :users_and_pages
  
  before do
    @page = pages(:home)
    assigns[:page] = @page
    assigns[:meta] = []
    assigns[:buttons_partials] = []
  end
  
  describe "without other extensions" do
  
    before do
      render '/admin/pages/edit'
    end
  
    it "should have image and link popups" do
      popups_section.should have_image_popup
      popups_section.should have_link_popup
    end
  
    it "should not show attachments in the popups without the page_attachments extension" do
      popups_section.should have_image_popup do
        popups_section.should_not have_attachment_radio_button
        popups_section.should_not have_image_select
      end
      popups_section.should have_link_popup do
        popups_section.should_not have_attachment_radio_button
        popups_section.should_not have_attachment_select
      end
    end
    it "should not show email option in the link popup without the enkoder_tags extension" do
      # Assuming this exetnsion is being developed in isolation
      Page.instance_methods.include?("tag:enkode_mailto") # Ensuring enkode_mailto extension is not installed
      popups_section.should_not have_email_radio_button
    end
  end

  describe 'when enkoder_tags extension is installed' do
  
    before do
      class Page
        tag("enkode_mailto") { return "" } # Mock enkode_mailto extension
      end
      render '/admin/pages/edit'
    end
  
    after do
      class Page
        undef_method("tag:enkode_mailto")
      end
    end
  
    it "should show email option in the link popup with the enkoder_tags extension" do
      popups_section.should have_link_popup do
        popups_section.should have_email_radio_button
      end
    end
  end

  describe 'when page_attachments extension is installed' do
  
    it "should display attachment options in the link and image popups" do
      @attachment = mock("attachment one")
      @attachment.stub!(:filename).and_return("test.jpg")
      assigns[:page].stub!(:attachments).and_return([@attachment])
      render '/admin/pages/edit'
    
      popups_section.should have_image_popup do
        popups_section.should have_attachment_radio_button
        popups_section.should have_image_select
      end
      popups_section.should have_link_popup do
        popups_section.should have_attachment_radio_button
        popups_section.should have_attachment_select
      end
    end
  
    it "should show a helpful message instead of a select because there are no attachments" do
      assigns[:page].stub!(:attachments).and_return([])
      render '/admin/pages/edit'
    
      popups_section.should have_image_popup do
        popups_section.should have_attachment_radio_button
        popups_section.should_not have_image_select
        popups_section.should have_tag("div#image_transform_input_attachment", /There are no images attached to this page./)
      end
      popups_section.should have_link_popup do
        popups_section.should have_attachment_radio_button
        popups_section.should_not have_attachment_select
        popups_section.should have_tag("div#transform_input_attachment", /There are no files attached to this page./)
      
      end
    end
  end
end

def popups_section
  response.capture(:popups)
end
def have_image_popup
  have_tag('div#image-popup')
end
def have_link_popup
  have_tag("div#link-popup")
end
def have_attachment_radio_button
  have_tag("input[name=?][value=?]", "transform_choice", "attachment")
end
def have_email_radio_button
  have_tag("input[name=?][value=?]", "transform_choice", "email")
end
def have_image_select
  have_tag("select#img_attachment_text")
end
def have_attachment_select
  have_tag("select#attachment_text")
end