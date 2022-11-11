# await: *await*

require 'spec_helper'

describe 'hooks' do
  describe 'before' do
    context 'async' do
      let(:raise_before_error) { false }
      before do
        delay_with_promise 0 do
          raise 'problem in before' if raise_before_error
          @test_value = 42
        end
      end

      context 'with sync subject' do
        subject { 42 }

        context 'succeeds' do
          it { is_expected.to eq @test_value }
        end

        context 'before :each fails properly' do
          let(:raise_before_error) { true }

          it 'should not reach the example' do
            fail 'we reached the example and we should not have!'
          end
        end

        context 'match fails properly' do
          it { is_expected.to_not eq @test_value }
        end

        context 'async match' do
          it 'succeeds' do
            delay_with_promise 0 do
              expect(subject).to eq @test_value
            end
          end

          it 'fails properly' do
            delay_with_promise 0 do
              expect(subject).to_not eq @test_value
            end
          end
        end
      end

      context 'with async subject' do
        let(:raise_before_subj_error) { false }

        subject do
          delay_with_promise 0 do
            raise 'problem in subject' if raise_before_subj_error
            42
          end
        end

        context 'both succeed' do
          it { expect(subject.await).to eq @test_value }
        end

        context 'both subject and before(:each) fail properly' do
          let(:raise_before_error) { true }
          let(:raise_before_subj_error) { true }

          it 'should not reach the example' do
            fail 'we reached the example and we should not have!'
          end
        end

        context 'before :each succeeds, assertion fails properly' do
          it { expect(subject.await).to_not eq @test_value }
        end

        context 'before :each fails properly' do
          let(:raise_before_error) { true }

          it 'should not reach the example' do
            fail 'we reached the example and we should not have!'
          end
        end

        context 'before :each succeeds, subject fails properly' do
          let(:raise_before_subj_error) { true }

          it 'should not reach the example' do
            fail 'we reached the example and we should not have!'
          end
        end

        context 'async match' do
          it 'succeeds' do
            delay_with_promise 0 do
              expect(subject.await).to eq @test_value
            end
          end

          it 'fails properly' do
            delay_with_promise 0 do
              expect(subject.await).to_not eq @test_value
            end
          end
        end
      end
    end

    context 'sync' do
      context 'with sync subject' do
        subject { 42 }

        context 'context' do
          context 'success' do
            before :context do
              $before_context_both_sync = 22
            end

            before do
              raise "$before_context_both_sync should already be 22!" unless $before_context_both_sync == 22
              @test_value = 42
            end

            it { is_expected.to eq @test_value }
          end

          context 'fails properly' do
            before :context do
              raise 'it failed in the before context!'
              $before_context_both_sync = 55
            end

            before do
              raise "we reached before:each and we should not have!" if $before_context_both_sync == 55
            end

            it 'should not reach the example' do
              fail 'we reached the example and we should not have!'
            end
          end
        end

        context 'succeeds' do
          before do
            @test_value = 42
          end

          it { is_expected.to eq @test_value }
        end

        context 'before :each fails properly' do
          before do
            raise 'before :each failed properly'
          end

          it 'should not reach the example' do
            fail 'we reached the example and we should not have!'
          end
        end

        context 'first before :each in chain triggers failure' do
          before do
            raise 'first before :each fails, this is correct'
          end

          context 'inner context' do
            before do
              raise 'we reached the inner before :each and we should not have'
            end

            it 'should not reach the example' do
              fail 'we reached the example and we should not have!'
            end
          end
        end

        context 'match fails properly' do
          before do
            @test_value = 42
          end

          it { is_expected.to_not eq @test_value }
        end
      end
    end
  end
end
