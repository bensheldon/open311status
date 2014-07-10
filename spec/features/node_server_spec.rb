require 'rails_helper'

describe 'Node Server' do
  before :all do
    @node_server = NodeServer.start
  end

  after :all do
    @node_server.stop
  end

  it "listens on expect port (#{ RSpec.configuration.node_server_port })" do
    expect(@node_server.stdout).to match(/server listening port=#{ RSpec.configuration.node_server_port }/i)
  end

  it 'returns status:ok' do
    body = open "http://localhost:#{ @node_server.port }/", &:read
    json =  JSON.parse body
    expect(json['status']).to eq 'ok'
  end
end
