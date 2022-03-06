require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Flutter do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ flutter }).should.be.instance_of Command::Flutter
      end
    end
  end
end

