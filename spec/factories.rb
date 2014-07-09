FactoryGirl.define do
	factory :user do
		name		"JackNewman"
		email		"jack@lolki.com"
		password	"testpass"
		password_confirmation	"testpass"
	end
end