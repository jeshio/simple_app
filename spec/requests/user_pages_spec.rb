require 'spec_helper'

describe "UserPages" do
    subject { page }
    let(:user) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:admin) }

    describe "index" do
    	before(:each) do
    		sign_in user
    		visit users_path
    	end

    	it { should have_title('All users') }
    	it { should have_content('All users') }

        describe "pagination" do
            before(:all) do
                User.delete_all
                30.times { FactoryGirl.create(:user) }
            end

            it { should have_selector('div.pagination') }

            it "should list each user" do
                User.paginate(page: 1).each do |user|
                    expect(page).to have_selector('li', text: user.name)
                end
            end

        end

        describe "delete links" do

            it { should_not have_link('delete') }

            describe "as an admin user" do

                before do
                    sign_in admin
                    visit users_path
                end

                it { should have_link('delete', href: user_path(User.first)) }

                it "should be able to delete another user" do
                    expect { click_link('delete', match: :first) }.to change(User, :count).by(-1)
                end

                describe "submitting a DELETE request to the Users#destroy action" do
                    before do
                        sign_in admin, no_capybara: true
                        delete user_path(admin)
                    end
                    specify { expect(response).to redirect_to(root_url) }
                end

                it { should_not have_link('delete', href: user_path(admin)) }


            end

            describe "as non-admin user" do
                let(:user) { FactoryGirl.create(:user) }
                let(:non_admin) { FactoryGirl.create(:user) }

                before { sign_in non_admin, no_capybara: true }

                describe "submitting a DELETE request to the Users#destroy action" do
                    before { delete user_path(user) }
                    specify { expect(response).to redirect_to(root_url) }
                end
            end
        end
    end

    describe "profile page" do
        let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Double") }
        let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "KILL!!") }

    	before { visit user_path(user) }

    	it { should have_content(user.name) }
    	it { should have_title(user.name) }

        describe "microposts list" do
            it { should have_content(m1.content) }
            it { should have_content(m2.content) }
            it { should have_content(user.microposts.count) }
        end

    end

    describe "edit" do
        before do 
        	sign_in user
        	visit edit_user_path(user)
        end

        describe "page" do
            it { should have_content('Update your profile') }
            it { should have_title('Edit user') }
            it { should have_link('change', href: 'http://gravatar.com/emails') }
        end

        describe "with invalid information" do
            before { click_button "Save" }

            it { should have_content('error') }
        end

        describe "with valid information" do
        	let(:new_name)	{ "New Name" }
        	let(:new_email)	{ "new@mail.com" }

        	before do
        		fill_in "Name",				with: new_name
        		fill_in "Email",			with: new_email
        		fill_in "Password",			with: user.password
        		fill_in "Confirmation",	with: user.password
        		click_button "Save"
        	end

        	it { should have_title(new_name) }
        	it { should have_selector('div.alert.alert-success') }
        	it { should have_link('Sign out', href: signout_path) }
        	specify { expect(user.reload.name).to eq new_name }
        	specify { expect(user.reload.email).to eq new_email }
        end

        describe "forbidden attributes" do
          let(:params) do
            { user: { admin: true, password: user.password,
                      password_confirmation: user.password } }
          end
          before do
            sign_in user, no_capybara: true
            patch user_path(user), params
          end
          specify { expect(user.reload).not_to be_admin }
        end
    end

    describe "for signed users" do

        before { sign_in user, no_capybara: true }

        describe "visit 'Sign up' page" do
          before { get signup_path }

          specify { expect(response).to redirect_to(root_url) }
        end
    end

    describe "signup page" do
    	before { visit signup_path }
        let(:submit) { "Save" }

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
