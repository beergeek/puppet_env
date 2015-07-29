require 'spec_helper'
describe 'profiles' do
  let(:facts) {
    {
      :kernel         => 'Linux',
      :osfamily       => 'RedHat',
      :concat_basedir => '/tmp',
    }
  }

  context 'default' do
    it { should compile.with_all_deps }
  end
end
