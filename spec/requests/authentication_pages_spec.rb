require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  describe "signin page" do
  	before { visit signin_path }

  	it { should have_content("Sign in") }
  	it { should have_title("Sign in") }

  	describe "with invalid info" do
  		before { click_button "Sign in" }

  		it { should have_title("Sign in") }
  		it { should have_error_message() }

      it { should_not have_link("Users") }
      it { should_not have_link("Profile") }
      it { should_not have_link("Settings") }
      it { should_not have_link("Sign out") }
      it { should have_link("Sign in") }

  		describe "after visiting another page" do
  			before { click_link("Home") }
  			it { should_not have_error_message() }
  		end

  	end

  	describe "with valid info" do

  		before do
  			sign_in user
  		end

  		it { should have_title(user.name) }
      it { should have_link("Users",        href: users_path) }
      it { should have_link("Profile",      href: user_path(user)) }
  		it { should have_link("Settings",			href: edit_user_path(user)) }
  		it { should have_link("Sign out",			href: signout_path) }
  		it { should_not have_link("Sign in",	href: signin_path) }
  	end
  end
  describe "authorization" do
    let(:user) { FactoryGirl.create(:user) }
  
    describe "for non-signed users" do

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          sign_in user
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end

        describe "request 'Sign in' page" do
          before do
            delete signout_path
            sign_in user
          end

          it "should render the profile page" do
            expect(page).to have_title(user.name)
          end
        end

      end
    end

    describe "as wrong user" do
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong2@mail.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end