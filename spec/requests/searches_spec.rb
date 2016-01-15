require 'spec_helper'
describe "Search pages" do
  describe "Home page" do
    it "should have the content '差评网'" do
      visit '/search/index'
      expect(page).to have_content('差评网')
    end
  end
end