require 'spec_helper'

describe "Static pages" do
  
  subject { page }
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end
  
  describe "Home page" do
    before { visit root_path }
    let(:heading) { 'Sample App' }
    let(:page_title) { '' }
    
    it_should_behave_like "all static pages"
    it { should_not have_selector('title', text: "| Home") }
    
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem Ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end
      
      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li#micropost-#{item.id}", text: item.content)
        end
      end
      
      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end
        
        it { should have_link("0 following"), href: following_user_path(user) }
        it { should have_link("1 followers"), href: following_user_path(user) }
      end
      
      describe "sidebar microposts count" do
        
        it "should have proper count" do
          page.should have_selector('span', text: "#{user.microposts.count} micropost")
        end
        
        describe "proper pluralization" do
          it "should be plural with multiple microposts" do
            user.microposts.delete_all
            FactoryGirl.create(:micropost, user: user, content: "Lorem Ipsum")
            FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
            visit root_path
            
            page.should have_selector('span', text: "2 microposts")
          end
          
          it "should be plural with 0 microposts" do
            user.microposts.delete_all
            visit root_path
            page.should have_selector('span', text: "0 microposts")
          end
          
          it "should be singular with 1 micropost" do
            user.microposts.delete_all
            FactoryGirl.create(:micropost, user: user, content: "Lorem Ipsum")
            visit root_path
            
            page.should have_selector('span', text: "1 micropost")
          end
        end
      end
      
      describe "pagination" do
        before(:all) { 30.times { FactoryGirl.create(:micropost, user: user) } }
        after(:all) { user.microposts.delete_all }
        
        it { should have_selector('div.pagination') }
        
        it "should list each micropost" do
          user.microposts.paginate(page: 1).each do |item|
            page.should have_selector("li#micropost-#{item.id}", text: item.content)
          end
        end
      end
      
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }
    
    it_should_behave_like "all static pages"
  end
  
  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }
    
    it_should_behave_like "all static pages"
  end
  
  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }
    
    it_should_behave_like "all static pages"
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign Up')
    click_link "sample app"
  end
  
end