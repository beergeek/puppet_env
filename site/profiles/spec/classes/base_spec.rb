require 'spec_helper'

context 'profiles::base' do
  let(:facts) {
    {
      :kernel                     => 'Linux',
      :osfamily                   => 'RedHat',
      :operatingsystem            => 'RedHat',
      :operatingsystemmajrelease  => '6',
      :concat_basedir             => '/tmp',
      :pe_concat_basedir          => '/tmp',
    }
  }

  context 'defaults' do

    it { should compile.with_all_deps }

  end

end
