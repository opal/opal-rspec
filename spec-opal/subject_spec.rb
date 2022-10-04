# await: *await*

require 'spec_helper'

describe 'subject' do
  context 'sync' do
    context 'named' do
      subject(:named_subject) { [1, 2, 3] }

      it "should be the subject" do
        subject.should be_kind_of(Array)
      end

      it "should be the named subject" do
        subject.should eql(named_subject)
      end
    end

    context 'unnamed' do
      subject { 42 }

      context 'passes' do
        it { is_expected.to eq 42 }
      end

      context 'assertion fails properly' do
        it { is_expected.to eq 43 }
      end

      context 'fails properly during subject create' do
        subject do
          raise 'did not work'
        end

        it { is_expected.to eq 42 }
      end
    end
  end

  context 'async' do
    describe 'assertion' do
      subject do
        delay_with_promise 0 do
          42
        end
      end

      context 'explicit async' do
        it 'passes' do
          delay_with_promise 0 do
            expect(subject.await).to eq 42
          end
        end

        it 'fails properly' do
          delay_with_promise 0 do
            expect(subject.await).to eq 43
          end
        end
      end

      context 'implicit' do
        context 'passes' do
          it { expect(subject.await).to eq 42 }
        end

        context 'fails properly' do
          it { expect(subject.await).to eq 43 }
        end
      end
    end

    context 'fails properly during creation' do
      subject do
        delay_with_promise 0 do
          raise 'did not work'
        end
      end

      context 'implicit usage' do
        it { expect(subject.await).to eq 42 }
      end

      it 'explicit async' do
        delay_with_promise 0 do
          expect(subject.await).to eq 42
        end
      end
    end
  end
end
