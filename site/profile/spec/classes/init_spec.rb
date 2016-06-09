require 'spec_helper'
describe 'profile' do

  context 'with defaults for all parameters' do
    it { is_expected.to compile.with_all_deps }
  end
end
