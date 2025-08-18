require "rails_helper"

RSpec.describe "ActionCable Integration", type: :feature do
  describe "Tailwindcss::Compiler::Channel" do
    context "when ActionCable.server has no logger" do
      before do
        @original_logger = ActionCable.server.logger if ActionCable.server
        ActionCable.server.logger = nil if ActionCable.server
      end
      
      after do
        ActionCable.server.logger = @original_logger if ActionCable.server
      end
      
      it "does not raise error when broadcasting CSS changes" do
        expect {
          Tailwindcss::Compiler::Channel.broadcast_css_changed
        }.not_to raise_error
      end
      
      it "sets a logger on ActionCable.server if missing" do
        Tailwindcss::Compiler::Channel.broadcast_css_changed
        expect(ActionCable.server.logger).not_to be_nil if ActionCable.server
      end
    end
    
    context "when ActionCable.server has a logger" do
      before do
        ActionCable.server.logger = Logger.new($stdout) if ActionCable.server
      end
      
      it "successfully broadcasts CSS changes" do
        expect {
          Tailwindcss::Compiler::Channel.broadcast_css_changed
        }.not_to raise_error
      end
    end
    
    context "when ActionCable is not loaded" do
      before do
        @action_cable = ActionCable if defined?(ActionCable)
        Object.send(:remove_const, :ActionCable) if defined?(ActionCable)
      end
      
      after do
        Object.const_set(:ActionCable, @action_cable) if @action_cable
      end
      
      it "does not raise error" do
        expect {
          Tailwindcss.compile_css!
        }.not_to raise_error
      end
    end
  end
end