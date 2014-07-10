require 'spec_helper'

describe "UserPages" do
    subject { page }

    describe "profile page" do
        let(:user) { FactoryGirl.create(:user) }
    	before { visit user_path(user) }

    	it { should have_content(user.name) }
    	it { should have_title(user.name) }

    end

    describe "signup page" do
    	before { visit signup_path }
        let(:submit) { "Create my account" }

    	it { should have_content('Sign Up') }

    	it { should have_title(full_title('Sign Up')) }

        describe "with invalid information" do
            it "create of the invalid user" do
                expect { click_button submit }.not_to change(User, :count)
            end

            describe "after submission" do
                before { click_button submit }

                it { should have_title("Sign Up") }
                it { should have_content("errors") }
                it { should have_selector('form input') }
            end

        end

        describe "with valid information" do
            before do
                fill_in "Name",         with: "Test Name"
                fill_in "Email",        with: "test@test.ru"
                fill_in "Password",     with: "testPass"
                fill_in "Confirmation", with: "testPass"
            end

            it "should create user" do
                expect { click_button submit }.to change(User, :count).by(1)
            end

            describe "after saving the user" do
                before { click_button submit }
                let(:user) { User.find_by(email: "test@test.ru") }

                it { should have_link('Sign out') }
                it { should have_title(user.name) }
                it { should have_success_message('Welcome') }

                describe "followed by signout" do
                    before { click_link("Sign out") }
                    it { should have_link('Sign in') }
                end
                
            end
        end

    end

end
