describe 'before hooks' do
  # describe 'async before' do
#     context 'sync subject' do
#       before do
#         promise = Promise.new
#         # self/instance variable will not work inside delay
#         set_test_val = lambda {|v| @test_value = v}
#         delay 1 do
#           set_test_val[42]
#           promise.resolve
#         end
#         promise
#       end
#
#       subject { 42 }
#
#       context 'succeeds' do
#         async_it { is_expected.to eq @test_value }
#       end
#
#       context 'before fails properly' do
#         pending 'write this'
#       end
#
#       context 'match fails properly' do
#         pending 'write this'
#       end
#     end
#
#     context 'async subject' do
#       subject do
#         promise = Promise.new
#         delay 1 do
#           promise.resolve 42
#         end
#         promise
#       end
#
#       context 'both succeed' do
#         pending 'write this'
#       end
#
#       context 'both fail properly' do
#         pending 'write this'
#       end
#
#       context 'before succeeds, assertion fails properly' do
#         pending 'write this'
#       end
#
#       context 'before fails properly' do
#         pending 'write this'
#       end
#
#       context 'match fails properly' do
#         pending 'write this'
#       end
#     end
#   end
  
  describe 'sync before' do  
    subject { 42 } 
  
    context 'succeeds' do
      before do
        @test_value = 42
      end
    
      it { is_expected.to eq @test_value }
    end
  
    context 'before fails properly' do
      before do
        raise 'something did not work right'
      end
    
      it { is_expected.to eq @test_value }
    end
  
    context 'match fails properly' do
      before do
        @test_value = 42
      end
    
      it { is_expected.to_not eq @test_value }
    end
  end  
end
