class ::RSpec::Mocks::TargetBase
  OPAL_NON_MOCKABLE_TYPES = [String, Number]

  def initialize(target)
    raise "#{target.class} #{target} cannot be used for mocking in Opal!" if OPAL_NON_MOCKABLE_TYPES.include?(target.class)
    @target = target
  end
end
