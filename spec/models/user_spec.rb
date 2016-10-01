require 'spec_helper'

describe User do

	before { @user = User.new(name: "Example User", uniq_user_name: "Example",
                     password: "foobar", password_confirmation: "foobar")}

	subject { @user }

	it { should respond_to(:name)}
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts)}
  it { should respond_to(:feed)}

	it {should be_valid}
  it {should_not be_admin}

  describe "with admin attributes set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it {should be_admin}
  end

	describe "when name is not present" do
		before {@user.name = ""}
		it {should_not be_valid}
	end

	describe "when name is too long" do
		before {@user.name = "a" * 51}
		it {should_not be_valid}
	end

end




















