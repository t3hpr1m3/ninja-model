require 'spec_helper'

describe NinjaModel do
  it { NinjaModel.should respond_to(:logger) }

  it 'should accept a logger' do
    orig_logger = NinjaModel.logger
    logger = mock('logger')
    NinjaModel.set_logger(logger)
    NinjaModel.logger.should eql(logger)
    NinjaModel.set_logger(orig_logger)
  end
end
