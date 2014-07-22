require 'spec_helper'

describe User do

	let(:name_len) { 50 }
  
  # Действия до начала тестирования
  before { @user = User.new(name: "Name", email: "test@mail.ru",
  	password: "test123", password_confirmation: "test123") }

  subject { @user }

  # Проверка на присутствие поля
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }

  it { should be_valid }
  it { should_not be_admin }

  describe "micropost associations" do

    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "return value of authenticate method" do
	  before { @user.save }
	  let(:found_user) { User.find_by(email: @user.email) }

	  describe "with valid password" do
	    it { should eq found_user.authenticate(@user.password) }
	  end

	  describe "with invalid password" do
	    let(:user_for_invalid_password) { found_user.authenticate("invalid") }

	    it { should_not eq user_for_invalid_password }
	    # specify - синоним it
	    specify { expect(user_for_invalid_password).to be_false }
	  end
	end

	describe "with a password that's too short" do
	  before { @user.password = @user.password_confirmation = "a" * 5 }
	  it { should be_invalid }
	end


  describe "when password is not present" do
  	before { @user.password = @user.password_confirmation = " " }
  	it { should_not be_valid }
  end

  describe "when password doesn't match confirm" do
  	before { @user.password_confirmation = "mismatch" }
  	it { should_not be_valid }
  end

  describe "when name is empty" do
  	before { @user.name = " " }
  	it { should_not be_valid }
  end

  describe "when email is not present" do
  	before { @user.email = " " }
  	it { should_not be_valid }
  end

  describe "when name is a very long" do
  	before { @user.name = "a" * (name_len + 1) }
  	it { should_not be_valid }
  end

  describe "check downcase to email before adding" do
  	before do
  		@user.email.upcase!
  		@user.save
  		@user.reload
  	end
  	subject { @user.email }

  	it { should eq @user.email.downcase }
  end

  describe "when email format is invalid" do
  	it "should be invalid" do
	  	addresses = %w[useR@foo,com usee@f+om.com res.s_ndd.com good@mail.c-r oo@bar..com]
	  	addresses.each do |invalid_mail|
	  		@user.email = invalid_mail
	  		expect(@user).not_to be_valid
  		end
  	end
  end

  describe "when email format is valid" do
  	it "should be valid" do
	  	addresses = %w[user@foo.com us_e+e@fom.com res.s@ndd.ru gOOd@Ma-il.moBy]
	  	addresses.each do |valid_mail|
	  		@user.email = valid_mail
	  		expect(@user).to be_valid
  		end
  	end
  end

  describe "when email address is already taken" do
  	before do
  		user_dup = @user.dup
  		user_dup.email = @user.email.upcase
  		user_dup.save
  	end

  	it { should_not be_valid }
  end

end
