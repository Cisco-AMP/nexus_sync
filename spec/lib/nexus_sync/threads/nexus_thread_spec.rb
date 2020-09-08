require 'nexus_sync/threads/nexus_thread'

RSpec.describe NexusSync::NexusThread do
  before(:each) do
    @core = double
  end

  describe 'when started' do
    it 'raises an unimplemented error' do
      error = 'ERROR: The method NexusSync::NexusThread.start hasn\'t yet been implemented for NexusSync::NexusThread'
      thread = NexusSync::NexusThread.new(@core)
      expect{ thread.join }.to raise_error(RuntimeError, error)
    end
  end
end
