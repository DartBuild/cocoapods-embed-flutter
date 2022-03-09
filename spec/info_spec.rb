require_relative 'spec_helper'

describe 'Plugin info test' do
  it 'checks name' do
    CocoapodsEmbedFlutter::NAME.should.equal 'cocoapods-embed-flutter'
  end
end