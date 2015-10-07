describe 'Opal ExpectationTarget' do
  context 'when constructed via #expect' do
    it 'fails an invalid negative expectation' do
      # Fixnum = Numeric on Opal
      # message = /expected 5 not to be a kind of Fixnum/
      message = /expected 5 not to be a kind of Numeric/
      expect {
        expect(5).not_to be_a(Fixnum)
      }.to fail_with(message)
    end

    it 'fails an invalid negative expectation with a split infinitive' do
      # Fixnum = Numeric on Opal
      # message = /expected 5 not to be a kind of Fixnum/
      message = /expected 5 not to be a kind of Numeric/
      expect {
        expect(5).to_not be_a(Fixnum)
      }.to fail_with(message)
    end
  end
end
