describe 'hooks' do
  describe 'around' do
    RSpec.shared_context :around_specs do      
      before do
        @model = Object.new
        @test_in_progress = nil
      end

      before :all do
        @@around_stack = []
        @@around_completed = 0
        @@around_failures = []
      end
      
      after :all do
        raise @@around_failures.join "\n" if @@around_failures.any?
        raise 'hooks not empty!' unless @@around_stack.empty?
        unless @@around_completed == @@expected_around_hits
          msg = "Expected #{@@expected_around_hits} around hits but got #{@@around_completed} for #{self}"        
          `console.error(#{msg})`
        end        
      end     
      
      context 'matches' do        
        it 'async match' do
          delay_with_promise 0 do
            1.should == 1
          end
        end
        
        it 'sync match' do
          1.should == 1
        end   
        
        it 'sync fails properly' do
          1.should == 2
        end
        
        it 'another async match' do
          delay_with_promise 0 do
            1.should == 1
          end
        end
        
        it 'async match fails properly' do
          delay_with_promise 0 do
            1.should == 2
          end
        end     
      end
      
      context 'before(:each) fails' do
        before do
          raise 'before fails properly'
        end
        
        it 'should not reach the example' do
          fail 'we reached the example and we should not have!'
        end
      end
      
      context 'after(:each)' do
        context 'async' do
          after do
            # self/scope
            raise_err = raise_after_exception
            delay_with_promise 0 do
              raise 'after fails properly' if raise_err
            end
          end
          
          context 'passes' do
            let(:raise_after_exception) { false }
        
            it 'sync match passes' do
              1.should == 1
            end            
          end
          
          context 'fails' do
            let(:raise_after_exception) { true }
            
            it 'sync match passes' do
              1.should == 1
            end            
          end
        end
        
        context 'sync' do
          after do
            raise 'after fails properly' if raise_after_exception
          end
          
          context 'passes' do
            let(:raise_after_exception) { false }
        
            it 'sync match passes' do
              1.should == 1
            end            
          end
          
          context 'fails' do
            let(:raise_after_exception) { true }
            
            it 'sync match passes' do
              1.should == 1
            end            
          end
        end
      end      
    end
    
    let(:fail_before_example_run) { false }
    let(:fail_after_example_run) { false }
    let(:skip_run) { false }
    
    around do |example|
      raise 'around failed before example properly' if fail_before_example_run        
      look_for = example.description
      @@around_stack << look_for
      clean_ending = lambda do
        last = @@around_stack.pop
        @@around_failures << "Around hook kept executing even though test #{@test_in_progress} was running!" if @test_in_progress
        @@around_failures << "Around hooks are messed up because we expected #{look_for} but we popped off #{last}" unless last == look_for
        @@around_completed += 1
        raise 'around failed after example properly' if fail_after_example_run
      end
      if skip_run
        clean_ending.call
      else
        example.run.then do
          clean_ending.call
        end        
      end
    end
    
    context 'succeeds' do
      before :context do
        @@expected_around_hits = 10
      end
      
      include_context :around_specs
    end
    
    context 'fails before example' do
      before :context do
        @@expected_around_hits = 0
      end
      
      let(:fail_before_example_run) { true }
      
      include_context :around_specs
    end
    
    context 'fails after example' do
      before :context do
        @@expected_around_hits = 10
      end
      
      let(:fail_after_example_run) { true }
      
      include_context :around_specs
    end
    
    context 'skip' do
      before :context do
        @@expected_around_hits = 10
      end
      
      let(:skip_run) { true }
      include_context :around_specs
    end
  end
end
