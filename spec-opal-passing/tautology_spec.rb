require 'spec_helper'

RSpec.describe 'Tautologies' do
  before do
    @one = 1
  end

  it "keeps @one's content coherent" do
    expect(@one).to eq(1)
  end

  xit "is 5" do
    expect(2+2).to eq(5)
  end

  it 'is 4' do
    expect(1*4).to eq(4)
    expect("4".to_i).to eq(4)
    expect("4000"[0]).to eq(4.to_s)
  end
end
