require 'rails_helper'
describe "Search pages" do
  describe "Home page" do
    it "should have the content '差评网'" do
      visit '/search/index'
      expect(page).to have_content('差评网')
    end
  end
  describe "Users page" do
    it "should have the content '登录'" do
      visit '/search/index'
      expect(page).to have_content('登录')
    end
  end
end