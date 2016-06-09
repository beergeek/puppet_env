require 'spec_helper'
describe 'profile::base' do

  context 'as Linux' do
    let(:facts) {
      {
        :kernel => 'Linux',
      }
    }
    it { should contain_class('profile::dns') }
    it { is_expected.to compile.with_all_deps }
  end
end
