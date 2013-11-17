require 'user'

describe User do
  it '#initialize accepts a name' do
    expect(User.new('Jim').name).to eq('Jim')
  end

  it 'is an admin if name is Bob' do
    expect(User.new('Bob')).to be_admin
  end

  it 'is not an admin if name is not Bob' do
    expect(User.new('Jim')).to_not be_admin
  end
end
