FactoryGirl.define do
	factory :user do
		name		"Jack Newman"
		email		"jack@lolki.com"
		password	"testpass"
		password_confirmation	"testpass"
	end
end