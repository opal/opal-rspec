describe 'Opal yield_successive_args matcher' do
  include YieldHelpers
  extend YieldHelpers

  it 'has a description' do
    expect(yield_successive_args(1, 3).description).to eq("yield successive args(1, 3)")
    # symbols == string in opal
    # expect(yield_successive_args([:a, 1], [:b, 2]).description).to eq("yield successive args([:a, 1], [:b, 2])")
    expect(yield_successive_args([:a, 1], [:b, 2]).description).to eq('yield successive args(["a", 1], ["b", 2])')
  end
end
